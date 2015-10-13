export @generator

#
# generator macro that translates the body of a generator to a Julia implementation.
#
# example syntax:
#
# @generator GenName(subgen1, subgen2, ...) begin
#   generates: ["..", ".."]
#		method1 = begin ... end
#		method2(param) = begin ... end
#		function method3()
#      ...
#		end
# end
#
macro generator(gensig, genbody)
	
	# macro is passed:
	# (1) the 'signature' of the generator: generator name and (optionally) subgenerator arguments
	# (2) the 'body' of the generator: a block containing methods and metadata

	# extract and check the name of the generator and (zero or more) subgen parameters
	genname, subgenargs = extractfuncsig(gensig)
	
	# extractfuncsig returns nothing if there is a problem
	if genname == nothing
		error("The generator name and arguments are not valid: $(gensig)")
	end
	
	# check that all arguments are simple symbols: currently do not support typed arguments
	if any(arg -> (typeof(arg) != Symbol), subgenargs)
		error("Not all arguments to the generator are valid - remove any type specifications: $(genargs)")
	end
	
	# extract metadata and rules from the body of the generator
	metadata, rules = extractmetadataandrules(genbody)

	# rewrite rules as functions and transform constructs
	rulesblock, ruletransforminfo = transformrules(genname, subgenargs, rules)
	
	typeblock = constructtype(genname, subgenargs, metadata, ruletransforminfo)

	mergeexprs(typeblock, rulesblock)
	
end


#
# type to store information about generator rules
#
type RuleMethod
	functionname::Any
	args::Any
	body::Any
end


#
# extract metadata and rules from the body of the generator
#
# metadata syntax:
#		tag: value
#
# rule syntax:
#		method = begin ... end
#		method(param) = begin ... end
#		function method() ... end
#	  
function extractmetadataandrules(genbody::Expr)
	
	metadata = Dict{Symbol, Any}()  	# key is tag, value is value
	rules = Dict{Symbol, Vector{RuleMethod}}()			# key is rule name, value is vector of rule (args, bodies)
	
	extractmetadataandrulesfromblock(genbody, metadata, rules)
	
	metadata, rules
	
end

# 
# extract metadata and rules from the body of the generator
# separate from extractmetadataandrules function above so it may be called recursively should the 
# metadata and rules be enclosed in further begin ... end blocks at the top level
#
function extractmetadataandrulesfromblock(block::Expr, metadata::Dict{Symbol, Any}, rules::Dict{Symbol, Vector{RuleMethod}})
	
	# metadata and rules are defined at the top level
	for node in removelinenodes(block.args)
	
		if typeof(node) == Expr
			
			if node.head == :block
				extractmetadataandrulesfromblock(node, metadata, rules)
				continue
			end
			
			# metadata syntax tree pattern
			#		:(:)
			#			:key
			#			expr
			if node.head == :(:)
				colonargs = removelinenodes(node.args)
				if length(colonargs) == 2 && typeof(colonargs[1]) == Symbol
					metadata[colonargs[1]] = eval(colonargs[2])  # TODO could eval have unintended side effects?
					continue
				end
			end

			# function call syntax tree pattern tested by extractfuncdef - it returns nothing if not a function definition
			(rulename, ruleargs, rulebody) = extractfuncdef(node)
			if rulename != nothing
				rulemethods = get!(rules, rulename, RuleMethod[])
				push!(rulemethods, RuleMethod(nothing, ruleargs, rulebody)) # functionname assigned later, so now nothing
				# TODO - check here that arguments are consistent between rules of the same name?
				continue
			end
			
			# TODO recursively permit blocks within blocks to still be 'top level'
		end
		
		error("Unrecognised statement at the top level of the generator body: $(node)")	
		
	end
	
end

# global information during rule transformation
type RuleTransformInfo
	# Random offset for all choice point numbers for this generator. A random offset is used
	# to make it very unlikely that choice points from different generators would have the
	# same number.
	choicepointoffset::UInt
	numchoicepoints::UInt
	choicepointinfo::Dict{UInt, Dict{Symbol, Any}} # Map from choice point num to info dict
	genname::Symbol
	subgenargs::Vector{Symbol}
	rules::Dict{Symbol, Vector{RuleMethod}}
	rulefunctionnames::Dict{Symbol, Symbol} # mapping of user rule name to actual rule name to avoid issues when methods of same name already exist and can't be extended
	genparam::Symbol
	genarg::Expr
	stateparam::Symbol
	statearg::Expr
	function RuleTransformInfo(genname, subgenargs, rules, rulefunctionnames)
		choicepointoffset = rand63bitint() # all choice points numbers will come in sequence after this number
		genparam = :g
		stateparam = :s
		genarg = Expr(:(::), genparam, esc(genname))
		statearg = Expr(:(::), stateparam, :DefaultDerivationState)
		new(choicepointoffset, 0, Dict{Int, Dict{Symbol, Any}}(), genname, subgenargs, rules, rulefunctionnames, genparam, genarg, stateparam, statearg)
	end
end


#
# rewrite rules as standard functions, and transform constructs
# note that the rule is given a unique name - this is necessary to avoid conflicts with methods with the same name that can't be extended
#
function transformrules(genname, subgenargs, rules)
	
	ruleexprs = Expr[]
	
	# create unique function name for each rule to avoid clashes with existing methods in same context
	rulefunctionnames = [rulename=>uniquerulename(rulename) for rulename in keys(rules)]
	
	# create record to store all the relevant info for transforming rules
	rti = RuleTransformInfo(genname, subgenargs, rules, rulefunctionnames)
	
	# TODO sort(collect(rules)) to ensure predictable order?
	for (rulename, rulemethods) in rules

		# construct a rule choice point if there are multiple rules with the same name
		if length(rulemethods) > 1
			push!(ruleexprs, constructrulechoice(rulename, rulemethods, rti) )
		else
			rulemethods[1].functionname = rti.rulefunctionnames[rulename]
		end
		
		# rewrite rules as function definitions
		for rulemethod in rulemethods
			
			# transform constructs
			transformedbody = transformconstructs(rulemethod.body, rti)

			# if rule body is not already a block, make it so
			if (typeof(transformedbody) != Expr) || (transformedbody.head != :block)
				transformedbody = Expr(:block, transformedbody)
			end
						
			# rewrite rule -- regardless of the original form -- as a short form function
			rewrittenargs = [rti.genarg; rti.statearg; rulemethod.args]
			push!(ruleexprs, Expr(:(=), Expr(:call, esc(rulemethod.functionname), rewrittenargs...), transformedbody))
			
		end
		
	end
	
	Expr(:block, ruleexprs...), rti
	
end


#
# if there are multiple methods with the same rulename, then name them uniquely
# and create a function (with the original name) that calls one of the methods
#
function constructrulechoice(rulename, rulemethods, rti::RuleTransformInfo)

	# we use arguments from first method as arguments to new function implementing the rule choice
	ruleargs = rulemethods[1].args
	rewrittenargs = [rti.genarg; rti.statearg; ruleargs]

	# extract parameters from these args for calls made within the new function to the rule methods
	ruleparams = [extractparamfromarg(arg) for arg in ruleargs]
	rewrittenparams = [rti.genparam; rti.stateparam; ruleparams]
	
	# ensure unique name for chosenidx in case of other variable defined in context
	chosenidxvar = gensym("chosenidx")
	
	condexpr = nothing
	for idx in 1:length(rulemethods)
		
		# create unique name for method
		rulemethods[idx].functionname = uniquerulename(rulename)

		# call method with new name
		callexpr = Expr(:call, esc(rulemethods[idx].functionname), rewrittenparams...)
		
		# build conditional expr
		if condexpr == nothing
			condexpr = callexpr
		else
			condexpr = :( ($(esc(chosenidxvar)) == $(idx)) ? $(callexpr) : ($condexpr) )
		end

	end

	cpinfo = Dict{Symbol,Any}(:rulename => rulename, :min => 1, :max => length(rulemethods))
	cpid = recordchoicepoint(rti, RULE_CP, cpinfo)

	rulebody = Expr(:block, :( $(esc(chosenidxvar)) = chooserule($(rti.stateparam), $(cpid), $(length(rulemethods))) ), condexpr)
	
	Expr(:(=), Expr(:call, esc(rti.rulefunctionnames[rulename]), rewrittenargs...), rulebody)
	
end


#
# identify and transform GT-specific constructs
# in addition, escape non-GT function so that rest of the rule code uses the current module scope rather than GodelTest
#
function transformconstructs(node, rti::RuleTransformInfo)
	
	if islinenode(node)
		return node
	end

	callname, callparams = extractfunccall(node)
	if callname != nothing
		if issequencechoicepoint(callname, callparams, rti)
			return transformsequencechoicepoint(callname, callparams, rti)
		elseif isvaluechoicepoint(callname, callparams, rti)
			return transformvaluechoicepoint(node, callparams, rti)
		elseif isrulecall(callname, callparams, rti)
			return transformrulecall(callname, callparams, rti)
		elseif issubgencall(callname, callparams, rti)
			return transformsubgencall(callname, callparams, rti)
		end		
	end
	
	if typeof(node) == Expr
		if node.head == :call
			# esc'ing the function name ensures that it runs in the scope of the current module not the GodelTest module
			node.args = [esc(node.args[1]); [transformconstructs(arg, rti) for arg in node.args[2:end]]]		
		else
			node.args = [transformconstructs(arg, rti) for arg in node.args]
		end
	end
	
	return node

end

#
# transform sequence choice points of the form:
#		reps(:rule, min, max)
#		mult(:rule)
#		plus(:rule)
#	to:
#		GodelTest.choosereps(s, cpid, ()->rule(g,s), minreps, maxreps, rangeisliteral)
#
function transformsequencechoicepoint(construct, params, rti::RuleTransformInfo)

	if (length(params) < 1)
		error("$(construct) must specify function to call")
	end

	functocallexpr = transformconstructs(params[1], rti) # intended to call to another rule or subgen, but could be any arbitrary expression
	
	if construct == :mult

		if length(params) > 1
			error("$(construct) must have no parameters other than function to call")
		end

		minreps, minisliteral = 0, true
		maxreps, maxisliteral = typemax(Int), true

	elseif construct == :plus

		if length(params) > 1
			error("$(construct) must have no parameters other than function to call")
		end

		minreps, minisliteral = 1, true
		maxreps, maxisliteral = typemax(Int), true

	elseif construct == :reps

		if length(params) > 3
			error("$(construct) must have at most two parameters other than function to call")
		end

		if length(params) >= 2
			minreps, minisliteral = processpossiblyliteralparam(params[2], Int, rti)
		else
			minreps, minisliteral = 0, true
		end

		if length(params) >= 3
			maxreps, maxisliteral = processpossiblyliteralparam(params[3], Int, rti)
		else
			maxreps, maxisliteral = typemax(Int), true
		end

	else

		error("unrecognised sequence choice point construct") # shouldn't happen

	end

	cpinfo = Dict{Symbol, Any}()

	# record literal values in choice point info as an indicator to choice model that limit on range will not change
	if minisliteral
		cpinfo[:min] = minreps
	end
	if maxisliteral
		cpinfo[:max] = maxreps
	end

	# rangeisliteral parameter will avoid a further runtime check on type validity if both limits are literal
	rangeisliteral = minisliteral && maxisliteral

	cpid = recordchoicepoint(rti, SEQUENCE_CP, cpinfo)
	idxvar = gensym("idx")
	:( [ $(functocallexpr) for $(esc(idxvar)) in 1:(choosereps($(rti.stateparam), $(cpid), $(minreps), $(maxreps), $(rangeisliteral))) ] )
end


#
# transform value choice points of the form:
#		choose(type,...)
# (where parameters after the datatype constrain the range of the type)
# to:
#		GodelTest.choosenumber(s, cpid, datatype, minval, maxval, rangeisliteral)
# except for string datatypes that construct their own rules to emit strings satisfying a regular expression
#
function transformvaluechoicepoint(construct, params, rti::RuleTransformInfo)

	if (length(params) < 1) || (typeof(params[1]) != Symbol)
		error("first parameter to choose($(params[1]),...) must be a literal data type")
	end

	datatype = eval(params[1]) # TODO could eval perform side-effects here? should be OK since we know it is a symbol
	if (typeof(datatype) != DataType) || !isleaftype(datatype)
		error("first parameter to choose($(params[1]),...) must be a concrete data type")
	end

	if datatype <: Bool

		# follows same pattern as other 'numeric' types, which is possible since 0~false 1~true
		# we don't allow any possibility to restrict this range

		if length(params) > 1
			error("choose($(datatype)) must have no further parameter")
		end

		minval = false
		maxval = true
		rangeisliteral = true
		cpinfo = Dict{Symbol,Any}(:datatype=>datatype, :min=>minval, :max=>maxval)
		cpid = recordchoicepoint(rti, VALUE_CP, cpinfo)
		chooseexpr = :( choosenumber($(rti.stateparam), $(cpid), $(datatype), $(minval), $(maxval), $(rangeisliteral)) )
		# choosenumber is not esc'ed so will be transformed to GodelTest.choosenumber by macro hygiene

	elseif datatype <: Char

		# not currently supported
		# one issue is that returning valid (Unicode) chars is not straightforward - the domain is not easily defined: for example typemin / typemax
		# is not defined for the Char type
		error("choose($(datatype),...) is not currently supported")

	elseif datatype <: Real
		# note Char <: Real, and so is excluded above

		# here parameters can be used to define a range of possible values
		# this can either be done via literals or expression - in the former case, the literal values are recorded and passed to the choice model
		# since knowing the bound(s) of the valid range can enable a better model than one that must potentially varying ranges

		if length(params) > 3
			error("choose($(datatype),...) must have at most two further parameters")
		end

		if length(params) >= 2
			minval, minisliteral = processpossiblyliteralparam(params[2], datatype, rti)
		else
			minval, minisliteral = typemin(datatype), true
		end

		if length(params) >= 3
			maxval, maxisliteral = processpossiblyliteralparam(params[3], datatype, rti)
		else
			maxval, maxisliteral = typemax(datatype), true
		end

		cpinfo = Dict{Symbol,Any}(:datatype=>datatype)

		# record literal values in choice point info as an indicator to choice model that limit on range will not change
		if minisliteral
			cpinfo[:min] = minval
		end
		if maxisliteral
			cpinfo[:max] = maxval
		end

		# rangeisliteral parameter will avoid a further runtime check on type validity if both limits are literal
		rangeisliteral = minisliteral && maxisliteral

		cpid = recordchoicepoint(rti, VALUE_CP, cpinfo)
		chooseexpr = :( choosenumber($(rti.stateparam), $(cpid), $(datatype), $(minval), $(maxval), $(rangeisliteral)) )
		# choosenumber is not esc'ed so will be transformed to GodelTest.choosenumber by macro hygiene

	elseif datatype <: AbstractString
		# TODO it may be a bit ambitious to allow all concrete string subtypes, but let's see ;-)

		# string data types are handled differently from numeric ones: instead of a call to choosenumber,
		# a block of statementsis constructed to build strings that comply with the reguler expression
		# within the block, multiple choice points are likely to be used

		if length(params) > 2
			error("choose($(datatype),...) must have at most one further parameter")
		end

		regex = "" # interpreted as wildcard
		if length(params) >= 2
			if !(typeof(regex) <: AbstractString)
				error("regex in choose($(datatype),...) must be a literal string")
			end
			regex = params[2]
		end

		chooseexpr = transformchoosestring(regex, datatype, rti)

	else

		error("choose($(datatype),...) is not supported")

	end

	chooseexpr
	
end


# call to a rule becomes:
#   rule(g, s, ...)
function transformrulecall(rulename, ruleparams, rti::RuleTransformInfo)
	rewrittenparams = [rti.genparam; rti.stateparam; ruleparams]
	Expr(:call, esc(rti.rulefunctionnames[rulename]), rewrittenparams...)
	# rule is esc'ed so that it is interpreted in context of current module and not GodelTest
end


# call to a sub-generator becomes:
#		GodelTest.subgen(g, s, i)
# where i it the index of the sub-generators in the arguments
#   
function transformsubgencall(subgenname, subgenparams, rti::RuleTransformInfo)
	i = findfirst(rti.subgenargs, subgenname)
	if length(subgenparams) != 0
		# TODO
	end
	Expr(:call, :subgen, rti.genparam, rti.stateparam, i)
	# :subgen is not esc'ed so that it is interpreted in context of GodelTest and not current module
end





function constructtype(genname, subgenargs, metaInfo, rti::RuleTransformInfo)

	# code for the generator type
	# note that macro hygeine will ensure that variables/functions/types not explicitly esc'ed will be transformed 
	# into the context of the GodelTest module, which is what we require here
	quote
		type $(esc(genname)) <: Generator
			meta::Dict{Symbol, Any}
			statetype
			choicepointinfo::Dict{UInt, Dict{Symbol, Any}}
			rulefunctionnames::Dict{Symbol,Symbol}
			subgens::Vector{Generator}

			function $(esc(genname))(subgens::Vector = [])
				if length(subgens) != $(length(rti.subgenargs))
					error("Incorrect number of sub generators $(length(subgens))")
				end

				if !all([typeof(sg) <: Generator for sg in subgens])
					error("Not all subgenerators are of type GodelTest.Generator $(subgens)")
				end

				new($metaInfo, DefaultDerivationState, $(rti.choicepointinfo), $(rti.rulefunctionnames), subgens)
			end

			$(esc(genname))(subgens...) = $(esc(genname))(collect(subgens))
		end
	end
	
end



# test whether syntax tree node in an expression is a line node (i.e. a file and line location)
# (as of v0.3, LineNumberNode does not seem to occur)
islinenode(node) = ((typeof(node) == Expr) && (node.head == :line)) || (typeof(node) == LineNumberNode)


# remove nodes in array that are line nodes
removelinenodes(args) = filter(arg->!islinenode(arg),args)


# extract method signature into tuple (name, arguments)
# (1) standard long or short form: foo(bar) or foo(bar) = 
# (2) GT-specific no args form: foo
function extractfuncsig(node)
	if typeof(node) == Expr
		if node.head == :call # standard long or short form
			callargs = removelinenodes(node.args)
			if length(callargs) >= 1
				return (callargs[1], callargs[2:end])
			end
		end
	elseif typeof(node) == Symbol # GT-specific no args form
		return (node, [])
	end
	return (nothing,nothing)
end


# extract function definition into tuple (name, arguments, body)
# (1) long form: function foo(bar) ... end
# (2) short form: foo(bar) = ... 
# (3) GT-specific no args form: foo = ...
function extractfuncdef(node)
	if typeof(node) == Expr
		if (node.head == :function) || (node.head == :(=) )
			eqargs = removelinenodes(node.args)
			if length(eqargs) == 2
				(name, args) = extractfuncsig(eqargs[1])
				if name != nothing
					return (name, args, eqargs[2])
				end
			end
		end
	end
	return (nothing,nothing,nothing)
end


# parse function call into tuple (name, params)
# (1) standard form: foo(bar) = ... 
# (2) GT-specific no args form: foo
function extractfunccall(node)
	if typeof(node) == Expr
		if node.head == :call # standard long or short form
			callargs = removelinenodes(node.args)
			if length(callargs) >= 1
				return (callargs[1], callargs[2:end])
			end
		end
	elseif typeof(node) == Symbol
		return(node, [])
	end
	return (nothing,nothing)
end


# merge two expression into a block
# if both are already blocks, then combine contents as a single block
function mergeexprs(ex1::Expr, ex2::Expr)
	if ex1.head == :block && ex2.head == :block
		Expr(:block, ex1.args..., ex2.args...)
	else
		Expr(:block, ex1, ex2)
	end
end

# is a call to sequence choice point
issequencechoicepoint(callname, callparams, rti) = (callname in [:mult, :plus, :reps,])

# is a call to value choice point
isvaluechoicepoint(callname, callparams, rti) = (callname == :choose)

# is a call to a rule (in the same generator)
isrulecall(callname, callparams, rti) = haskey(rti.rules, callname)

# is a call to a subgen of the generator
issubgencall(callname, callparams, rti) = (callname in rti.subgenargs)


# We use 63 bit offset to ensure there is room to add choice points after the offset
# value. If we used 64 bit we might get too close to the end of the range...
function rand63bitint()
	candidate = rand(UInt64)
	while candidate > (2^63-1)
		candidate = rand(UInt64)
	end
	candidate
end

function recordchoicepoint(rti::RuleTransformInfo, cptype::Symbol, cpinfo::Dict)
	cpid = nextchoicepointnum(rti)
	cpinfo[:type] = cptype
	rti.choicepointinfo[cpid] = cpinfo
	cpid
end

# get a unique choice point num
function nextchoicepointnum(rti::RuleTransformInfo)
	rti.numchoicepoints += 1
	rti.choicepointoffset + rti.numchoicepoints
end

# generate a unique rule name
uniquerulename(rulename) = gensym(string(rulename))



# process a param that should be a specified literal datatype or an expression
# note: cannot simply check for Expr or not since call to GT-specific no-arg func would be non-Expr but is non-literal
function processpossiblyliteralparam(param, datatype, rti::RuleTransformInfo)
	paramisliteral = true
	try
		value = convert(datatype, param) # see if value can be interpreted as a literal of specified datatype
	catch
		paramisliteral = false # assume instread is not a literal
	end
	if !paramisliteral
		value = transformconstructs(param, rti) # we allow non-literal params to contain GT constructs too
	end
	value, paramisliteral
end

# extract an parameter name from the function argument expression 
# the argument *may*
#		- have type, e.g. x::Int
#		- have default value e.g. x=2
#		- be a named parameter
# TODO vargs (i.e. ...)
function extractparamfromarg(argexpr)
	if typeof(argexpr) == Symbol
		return argexpr
	end
	if (typeof(argexpr) == Expr)
		filteredargs = removelinenodes(argexpr.args)
		if (argexpr.head == :(::)) && (length(filteredargs) == 2)
			extractparamfromarg(filteredargs[1])
		end
	end
	if (argexpr.head == :kw) && (length(filteredargs) == 2) # :kw indicates parameter defaulting
		return extractparamfromarg(filteredargs[1])
	end
	if argexpr.head == :parameter # :parameter indicates parameter defaulting
		# TODO - difficulty here is that these named parameters come first, and when using them need to use a special syntax, so disallow for the moment
		error("currently cannot use named parameters in a rule choice rule")
	end
	error("cannot extract parameter name from argument definition")
end


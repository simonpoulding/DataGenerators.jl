
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
# note: we generally want to avoid the standard hygiene changes performed by the macro expander
# as the rule code should execute in the context in which the macro is called.  However, code added
# to handle the constructs (such as choice points) should operate in the context of the DataGenerators
# module.
# The ideal approach would be to apply hygiene to DataGenerators code, and then escape any user-defined rule code.  However
# since DataGenerators code is mixed very closely in AST with user code (for instance when a GT construct appears in 
# argument values passed to a function), this difficult to achieve correctly. For example, escaping all nodes
# apart from those that are GT construct will work in most cases, but fails if the user defines an anonymous
# function such i->... (e.g. in a call to map(..., )) as the escaped variable gives rise to an error (invalid
# assignment target)
#
# 
# 
macro generator(gensig, genbody)
	
	# macro is passed:
	# (1) the 'signature' of the generator: generator name and (optionally) subgenerator arguments
	# (2) the 'body' of the generator: a block containing methods and metadata

	# extract and check the name of the generator and (zero or more) subgen parameters
	genname, subgenargs = extractfuncsig(gensig, true) # true: allows permits function signature without parenthesis when there are no parameters
	
	# extractfuncsig returns nothing if there is a problem
	if genname == nothing
		error("The generator name and arguments are not valid: $(gensig)")
	end
	
	# check that all arguments are simple symbols: currently do not support typed arguments
	if any(arg -> (typeof(arg) != Symbol), subgenargs)
		error("Not all arguments to the generator are valid - remove any type specifications: $(genargs)")
	end
	
	# extract metadata and rules from the body of the generator
	metadata, generatorrules = extractmetadataandrules(genbody)

	# rewrite rules as functions and transform constructs
	gencontext = GeneratorContext(genname, subgenargs)
	transformrules!(generatorrules, gencontext)

	# construct and return code for generator type and methods that implement the rules
	typeblock = constructtype(genname, subgenargs, metadata, gencontext)
	methodsblock = constructmethods(generatorrules)
	
	tidyfinish = quote $(genname); end # avoid outputting the last method's name as result of macro; output type instead

	typeandmethods = mergeexprs(typeblock, methodsblock)
	
	esc(mergeexprs(typeandmethods, tidyfinish))
	
end


#
# context during rule transformation (e.g. generator name, choice points)
#
type GeneratorContext
	# Random offset for all choice point numbers for this generator. A random offset is used
	# to make it very unlikely that choice points from different generators would have the
	# same number.
	choicepointoffset::UInt
	numchoicepoints::UInt
	choicepointinfo::Dict{UInt, Dict{Symbol, Any}} # Map from choice point num to info dict
	genname::Symbol
	subgenargs::Vector{Symbol}
	rulemethodnames::Dict{Symbol, Symbol} # mapping of user rule name to actual methods name to avoid issues when methods of same name already exist and can't be extended
	genparam::Symbol
	genarg::Expr
	stateparam::Symbol
	statearg::Expr
	function GeneratorContext(genname, subgenargs)
		choicepointoffset = rand63bitint() # all choice points numbers will come in sequence after this number
		genparam = gensym(:g)
		stateparam = gensym(:s)
		genarg = :( $(genparam)::$(genname) )
		statearg = :( $(stateparam)::$(THIS_MODULE).DerivationState )
		new(choicepointoffset, 0, Dict{Int, Dict{Symbol, Any}}(), genname, subgenargs, Dict{Symbol, Symbol}(), genparam, genarg, stateparam, statearg)
	end
end

#
# holds a generator rule during transformation
#
type GeneratorRule
	rulename::Symbol
	args::Any
	body::Any
	methodname::Any
	function GeneratorRule(rulename, args, body, methodname=nothing)
		new(rulename, args, body, methodname)
	end
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
	generatorrules = Vector{GeneratorRule}() 
	
	extractmetadataandrulesfromblock(genbody, metadata, generatorrules)
	
	metadata, generatorrules
	
end

# 
# extract metadata and rules from the body of the generator
# separate from extractmetadataandrules function above so it may be called recursively should the 
# metadata and rules be enclosed in further begin ... end blocks at the top level
#
function extractmetadataandrulesfromblock(block::Expr, metadata::Dict{Symbol, Any}, generatorrules::Vector{GeneratorRule})
	
	# metadata and rules are defined at the top level
	for node in removelinenodes(block.args)
	
		if typeof(node) == Expr
			
			if node.head == :block
				extractmetadataandrulesfromblock(node, metadata, generatorrules)
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
				push!(generatorrules, GeneratorRule(rulename, ruleargs, rulebody))
				continue
			end
			
			# TODO recursively permit blocks within blocks to still be 'top level'
		end
		
		error("Unrecognised statement at the top level of the generator body: $(node)")	
		
	end
	
end

function constructtype(genname, subgenargs, metaInfo, gencontext::GeneratorContext)

	# code for the generator type
	# note that macro hygeine will ensure that variables/functions/types not explicitly esc'ed will be transformed 
	# into the context of the DataGenerators module, which is what we require here

	# we store also the current module at the time of calling this macro as the owning module of this new type:
	# this is so that rules are executed in the correct context when the generator is run since the same context
	# as this type is where the method corresponding to generator rules will be created.
	# it would be possible to derive the owning module from the fully specified type of the generator,
	# but there is currently no built-in Julia function to do this cleanly; instead we would need to 
	# perform some custom string-manipulation on the type name, and this wouldn't be very robust (e.g.
	# may not survive type-aliasing etc.)

	# Further note: Module is stored as a symbol in the type since deepcopy does not support fields of type Module,
	# and to recreate the Module type, we also need its parent
	
	quote
		type $(genname) <: $(THIS_MODULE).Generator
			meta::Dict{Symbol, Any}
			choicepointinfo::Dict{UInt, Dict{Symbol, Any}}
			rulemethodnames::Dict{Symbol,Symbol}
			subgens::Vector{$(THIS_MODULE).Generator}
			choicemodel::$(THIS_MODULE).ChoiceModel
			evalfn::Function
			function $(genname)(subgens::Vector = [])
				if length(subgens) != $(length(subgenargs))
					error("Incorrect number of sub generators $(length(subgens))")
				end

				if !all([typeof(sg) <: $(THIS_MODULE).Generator for sg in subgens])
					error("Not all subgenerators are of type $(THIS_MODULE).Generator $(subgens)")
				end
				cpinfo = $(gencontext.choicepointinfo)
				new($metaInfo, cpinfo, $(gencontext.rulemethodnames), subgens, $(THIS_MODULE).SamplerChoiceModel(cpinfo),
				 		ex->eval($(current_module()),ex))
			end

			$(genname)(subgens...) = $(genname)(collect(subgens))
		end
	end
	
end

function constructmethods(generatorrules::Vector{GeneratorRule})

	# construct methods for generator rules (as short form function since body is guaranteed to be a block)

	methodexprs = map(gm -> Expr(:(=), Expr(:call, gm.methodname, gm.args...), gm.body), generatorrules)
	Expr(:block, methodexprs...)

end




#
# main entry point -- transforms rules written with Data Generator constructs into standard Julia methods
#
function transformrules!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)

	# (1) choose(Type) where Type is a not a directly supported type, nor generator
	transformchoosetypes!(genrules, gencontext)

	# (2) choose(<: String, [regex])
	transformchoosestrings!(genrules, gencontext)

	# up to here is processing of syntactic sugar: expansion adds rules that use Data Generators constructs
	# (which will be processed in subsequent steps, so this sugar processing must occur first)
	# however, subsequent transforms change Data Generators constructs into standard Julia

	# (3) choose(<: Number, [min, [max]])
	transformchoosenumbers!(genrules, gencontext)

	# (4) choose(Gen) where Gen is a generator type (means include choice points into this generator) 
	# transformchoosegentypes!(genrules, gencontext)

	# (5) choose(subgen) where subgen is a generator instance (means call gen but don't include choice points)
	transformchoosesubgens!(genrules, gencontext)

	# (6) sequence choice point 
	transformsequencechoicepoints!(genrules, gencontext)

    # (7) transform signatures (method names and arguments)
	transformsignatures!(genrules, gencontext)

	# (8) create umbrella methods, and transform rule choice points
	createumbrellamethods!(genrules, gencontext)

	# (9) calls to other rules
	transformrulecalls!(genrules, gencontext)

	# (10) indirect calls to other rules - feature used to avoid long-running compilation as a result of (seemingly) recursive type inference
	transformindirectrulecalls!(genrules, gencontext)

	# (11) direct call to subgenerators (no longer supported)
	# transformdirectsubgencalls!(genrules, gencontext)

end


#
# transform all type choice points: choose(Type)
#
function transformchoosetypes!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, ischoosetype, transformchoosetype)
	end
end

# is a call to choose(Type) point
function ischoosetype(callname, callparams, gencontext)
	if (callname == :choose)
		if (length(callparams) >= 1)
			datatype = converttodatatype(callparams[1])
			# type must not be a directly supported type (e.g. Int64, String) nor a Generator
			if (typeof(datatype) <: Type) && !(datatype in GENERATOR_SUPPORTED_CHOOSE_TYPES) && !(datatype <: Generator)
				return true
			end
		end
	end
	false
end

# expand Type choice points of the using translator for Types
function transformchoosetype(callname, callparams, genrules, gencontext, matchfn, transformfn)

	datatype = converttodatatype(callparams[1])

	if length(callparams) > 2
		error("choose($(datatype)) must have no further parameters")
	end

	# attempt to make rulenames unique for additional type rules by adding a prefix containing a random 64-bit values
	# in particular, it is unlikely any user-defined (or auto-generated) rules will have names the same as rule generated
	# for this type
	rulenameprefix = "choosetype" * hex(rand(UInt64))
	# create rules for regex
	typerules = type_rules(datatype, rulenameprefix)
	# add rules to generator
	addrulesources(genrules, typerules)
	# replace choose with call to entry point for regex rules (the first rule)
	:( $(typerules[1].rulename)() )
	
end

#
# transform all string choice points: choose(StringType, [regex])
#
function transformchoosestrings!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, ischoosestring, transformchoosestring)
	end
end

# is a call to choose(String) point
function ischoosestring(callname, callparams, gencontext)
	if (callname == :choose)
		if (length(callparams) >= 1)
			datatype = converttodatatype(callparams[1])
			if (typeof(datatype) <: Type) && (datatype in GENERATOR_SUPPORTED_CHOOSE_STRING_TYPES)
				return true
			end
		end
	end
	false
end

# expand String choice points of the form:
#		choose(type,[regex])
# by creating additional rules to emit strings satisfying the regex
function transformchoosestring(callname, callparams, genrules, gencontext, matchfn, transformfn)

	datatype = converttodatatype(callparams[1])

	if length(callparams) > 2
		error("choose($(datatype),...) must have at most one further parameter")
	end

	regex = "" # interpreted as wildcard
	if length(callparams) >= 2
		if !(typeof(regex) <: AbstractString)
			error("regex in choose($(datatype),...) must be a literal string")
		end
		regex = callparams[2]
	end

	# attempt to make rulenames unique for additional regex rules by adding a prefix containing a random 64-bit values
	# in particular, it is unlikely any user-defined (or auto-generated) rules will have names the same as rule generated
	# for this regex
	rulenameprefix = "choosestring" * hex(rand(UInt64))
	# create rules for regex
	regexrules = DataGeneratorTranslators.regex_rules(regex, datatype, rulenameprefix)
	# add rules to generator
	addrulesources(genrules, regexrules)
	# replace choose with call to entry point for regex rules (the first rule)
	:( $(regexrules[1].rulename)() )
	
end



#
# transform value choice points with simple numeric (inc. Boolean) types
#

function transformchoosenumbers!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, ischoosenumber, transformchoosenumber)
	end
end


# is a call to value choice point
function ischoosenumber(callname, callparams, gencontext)
	if (callname == :choose)
		if (length(callparams) >= 1)
			datatype = converttodatatype(callparams[1])
			if (typeof(datatype) <: Type) && (datatype in GENERATOR_SUPPORTED_CHOOSE_NUMBER_TYPES)
				return true
			end
		end
	end
	false
end

# transform numeric value choice points of the form:
#		choose(type, [min, [max]])
# (where parameters after the datatype constrain the range of the type)
# to:
#		DataGenerators.choosenumber(s, cpid, datatype, minval, maxval, rangeisliteral)
function transformchoosenumber(callname, callparams, genrules, gencontext, matchfn, transformfn)

	datatype = converttodatatype(callparams[1])
	# thanks to ischoosenumber matching function, we know we that there is at least one param, and that it is a symbol

	if datatype <: Bool

		# follows same pattern as other 'numeric' types, which is possible since 0~false 1~true
		# we don't allow any possibility to restrict this range

		if length(callparams) > 1
			error("choose($(datatype)) must have no further parameters")
		end

		minval = false
		maxval = true
		rangeisliteral = true
		cpinfo = Dict{Symbol,Any}(:datatype=>datatype, :min=>minval, :max=>maxval)
		cpid = recordchoicepoint(gencontext, :value, cpinfo)
		chooseexpr = :( $(THIS_MODULE).choosenumber($(gencontext.stateparam), $(cpid), $(datatype), $(minval), $(maxval), $(rangeisliteral)) )

	else

		# here parameters can be used to define a range of possible values
		# this can either be done via literals or expression - in the former case, the literal values are recorded and passed to the choice model
		# since knowing the bound(s) of the valid range can enable a better model than one that must potentially varying ranges

		if length(callparams) > 3
			error("choose($(datatype),...) must have at most two further parameters")
		end

		# parameters themselves could be nested choose(Number, ...) expression, so transform these recursively:
		for i in 2:length(callparams)
			callparams[i] = transformfunccall(callparams[i], genrules, gencontext, matchfn, transformfn)
		end

		if length(callparams) >= 2
			minval, minisliteral = processpossiblyliteralparam(callparams[2], datatype, gencontext)
		else
			minval, minisliteral = typemin(datatype), true
		end

		if length(callparams) >= 3
			maxval, maxisliteral = processpossiblyliteralparam(callparams[3], datatype, gencontext)
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

		cpid = recordchoicepoint(gencontext, :value, cpinfo)
		chooseexpr = :( $(THIS_MODULE).choosenumber($(gencontext.stateparam), $(cpid), $(datatype), $(minval), $(maxval), $(rangeisliteral)) )

	end

	chooseexpr
	
end



#
# transform choose(subgen)
#

function transformchoosesubgens!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, ischoosesubgen, transformchoosesubgen)
	end
end

# is a call to value choice point
ischoosesubgen(callname, callparams, gencontext) = (callname == :choose) && (length(callparams) >= 1) && (callparams[1] in gencontext.subgenargs)

# call to a sub-generator becomes: DataGenerators.subgen(g, s, i) where i it the index of the sub-generators in the arguments  
function transformchoosesubgen(callname, callparams, genrules, gencontext, matchfn, transformfn)
	if length(callparams) > 1
		error("choose($(callparams[1])) must have no further parameters")
	end
	i = findfirst(gencontext.subgenargs, callparams[1])
	:( $(THIS_MODULE).subgen($(gencontext.genparam), $(gencontext.stateparam), $(i)) )
end



#
# transform all sequence choice points
#

function transformsequencechoicepoints!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, issequencechoicepoint, transformsequencechoicepoint)
	end
end

# is a call to sequence choice point
issequencechoicepoint(callname, callparams, gencontext) = (callname in [:mult, :plus, :reps,])

# transform sequence choice points of the form:
#		reps(:rule, min, max)
#		mult(:rule)
#		plus(:rule)
#	to:
#		DataGenerators.choosereps(s, cpid, ()->rule(g,s), minreps, maxreps, rangeisliteral)
function transformsequencechoicepoint(callname, callparams, genrules, gencontext, matchfn, transformfn)

	if length(callparams) < 1
		error("$(callname) must specify an expression to sequence")
	end

	# allow for nested sequence choice points by transforming the expression to sequence
	functocallexpr = transformfunccall(callparams[1], genrules, gencontext, matchfn, transformfn)

	# synatic sugar: intepret a symbol of a rule name as a no-parameter call to that rule
	functocallexpr = convertrulenametorulecall(functocallexpr, genrules)

	if callname == :mult

		if length(callparams) > 1
			error("$(callname) must have no parameters other than function to call")
		end

		minreps, minisliteral = 0, true
		maxreps, maxisliteral = typemax(Int), true

	elseif callname == :plus

		if length(callparams) > 1
			error("$(callname) must have no parameters other than function to call")
		end

		minreps, minisliteral = 1, true
		maxreps, maxisliteral = typemax(Int), true

	elseif callname == :reps

		if length(callparams) > 3
			error("$(callname) must have at most two parameters other than function to call")
		end

		if length(callparams) >= 2
			minreps, minisliteral = processpossiblyliteralparam(callparams[2], Int, gencontext)
		else
			minreps, minisliteral = 0, true
		end

		if length(callparams) >= 3
			maxreps, maxisliteral = processpossiblyliteralparam(callparams[3], Int, gencontext)
		else
			maxreps, maxisliteral = typemax(Int), true
		end

	else

		error("unrecognised sequence choice point construct $(callname)") # shouldn't happen

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

	cpid = recordchoicepoint(gencontext, :sequence, cpinfo)
	idxvar = gensym("idx")
	:( [ $(functocallexpr) for $(idxvar) in 1:($(THIS_MODULE).choosereps($(gencontext.stateparam), $(cpid), $(minreps), $(maxreps), $(rangeisliteral))) ] )

end



#
# transform rule signatures (name and args)
# rule name is converted to a unique method name; internal arguments are added
#

function transformsignatures!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)

	for genrule in genrules

		genrule.methodname = uniquemethodname(genrule.rulename)
		
		# if rule body is not already a block, make it so (so can be written as short form function)
		if (typeof(genrule.body) != Expr) || (genrule.body.head != :block)
			genrule.body = Expr(:block, genrule.body)
		end
		
		genrule.args = [gencontext.genarg; gencontext.statearg; genrule.args]
		
	end
	
end



#
# create an 'umbrella' method for each unique rule name
# the umbrella method is the entry point for the rule, and records rule entry and exit during generation
# for rule choice points (where there is more than one rule with the same name), it handles the selection of which rule is called
#

function createumbrellamethods!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)

	# group rules with the same name together (so we can process rule choice constructs)
	groupedrules = Dict{Symbol, Vector{GeneratorRule}}()
	for genrule in genrules
		rules = get!(groupedrules, genrule.rulename, Vector{GeneratorRule}())
		push!(rules, genrule)
		# TODO: check that arguments also match?
	end
	

	# TODO sort(collect(rules)) to ensure predictable order?
	for (rulename, rules) in groupedrules

		# assign a unique method name
		umbrellamethodname = uniquemethodname(rulename)
		# and store this since it is the method that must be called when the rule is executed
		gencontext.rulemethodnames[rulename] = umbrellamethodname

		#
		# call (one of) the method(s) for the rule(s)
		# if there is more than one rule, then create a rule choice point that determines which to call
		#

		# assume that all individual rules have the same set of arguments, and take these from the first rule
		umbrellaargs = rules[1].args

		# extract parameters from these args for calls made within the new function to the rule methods
		umbrellaparams = [extractparamfromarg(arg) for arg in umbrellaargs]
		
		if length(rules) > 1
			
			# if more than one rule with this name, then a rule choice point is required
			
			# ensure unique name for chosenidx in case of other variable defined in context
			chosenidxvar = gensym("chosenidx")
		
			condexpr = nothing
			for idx in 1:length(rules)
			
				# call method with new name
				callexpr = Expr(:call, rules[idx].methodname, umbrellaparams...)
			
				# build conditional expr
				if condexpr == nothing
					condexpr = callexpr
				else
					condexpr = :( ($(chosenidxvar) == $(idx)) ? $(callexpr) : ($condexpr) )
				end

			end

			cpinfo = Dict{Symbol,Any}(:rulename => rulename, :min => 1, :max => length(rules))
			cpid = recordchoicepoint(gencontext, :rule, cpinfo)

			umbrellabody = Expr(:block, :( $(chosenidxvar) = $(THIS_MODULE).chooserule($(gencontext.stateparam), $(cpid), $(length(rules))) ), condexpr)
			
		else
			
			# if only one method for this rule, simply call the method
				
			callexpr = Expr(:call, rules[1].methodname, umbrellaparams...)
			
			umbrellabody = Expr(:block, callexpr)
			
		end

		#
		# now 'wrap' rule body with calls to indicate the start and end of the rule:
		#
		# begin
		#	recordstartofrule(state, rulemethodname)
		# 	result = <rulebody block created in code above>
		#	recordendofrule(state, rulemethodname)
		#	result
		# end
		#
		# note: we use the umbrella method name (which might be somewhat obfuscated) rather than the rulename,
		# since the rulename need not be unique across a generator and its subgenerators
		
		resultvar = gensym("result")
		rulenameexpr = QuoteNode(umbrellamethodname)
		umbrellabody = Expr(:block,
			:( $(THIS_MODULE).recordstartofrule($(gencontext.stateparam), $(rulenameexpr)) ),
			:( $(resultvar) = $(umbrellabody) ), 
			:( $(THIS_MODULE).recordendofrule($(gencontext.stateparam)) ),
			:( $(resultvar) )
		)

		push!(genrules, GeneratorRule(rulename, umbrellaargs, umbrellabody, umbrellamethodname))

	end
	
end



#
# transform all call to rules by calling the umbrella method
#

function transformrulecalls!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, isrulecall, transformrulecall)
	end
end

# is a call to a generator rule if called function is a key to the list of rulemethods
isrulecall(callname, callparams, gencontext) = haskey(gencontext.rulemethodnames, callname)

# to call a method, call the umbrella method
function transformrulecall(callname, callparams, genrules, gencontext, matchfn, transformfn)
	umbrellamethodname = gencontext.rulemethodnames[callname]
	rewrittenparams = [gencontext.genparam; gencontext.stateparam; callparams]
	Expr(:call, umbrellamethodname, rewrittenparams...)
end


#
# transform all indirect call to rules by calling the umbrella method
#

function transformindirectrulecalls!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, isindirectrulecall, transformindirectrulecall)
	end
end

# is a call to a generator rule if called function is a key to the list of rulemethods
isindirectrulecall(callname, callparams, gencontext) = (callname == :rule) && length(callparams) >= 1

# to call a method, call a helper method in generation code
function transformindirectrulecall(callname, callparams, genrules, gencontext, matchfn, transformfn)
	rewrittenparams = [gencontext.genparam; gencontext.stateparam; callparams]
	:( $(THIS_MODULE).indirectrulecall($(rewrittenparams...)) )
end



#
# transform all direct calls to rules by calling the umbrella method (deprecated)
#

function transformdirectsubgencalls!(genrules::Vector{GeneratorRule}, gencontext::GeneratorContext)
	for genrule in genrules
		genrule.body = transformfunccall(genrule.body, genrules, gencontext, isdirectsubgencall, transformdirectsubgencall)
	end
end

# is a call to a subgen of the generator
isdirectsubgencall(callname, callparams, gencontext) = (callname in gencontext.subgenargs)

# call to a sub-generator becomes: DataGenerators.subgen(g, s, i)
# where i it the index of the sub-generators in the arguments  
function transformdirectsubgencall(callname, callparams, gencontext, matchfn, transformfn)
	warn("Direct calls to sub-generators are deprecated; please use: choose(<subgenname>)")
	i = findfirst(gencontext.subgenargs, callname)
	:( $(THIS_MODULE).subgen($(gencontext.genparam), $(gencontext.stateparam), $(i)) )
end



#
# Utility methods
#

# We use 63 bit offset to ensure there is room to add choice points after the offset
# value. If we used 64 bit we might get too close to the end of the range...
function rand63bitint()
	candidate = rand(UInt64)
	while candidate > (2^63-1)
		candidate = rand(UInt64)
	end
	candidate
end

function recordchoicepoint(gencontext::GeneratorContext, cptype::Symbol, cpinfo::Dict)
	cpid = nextchoicepointnum(gencontext)
	cpinfo[:type] = cptype
	gencontext.choicepointinfo[cpid] = cpinfo
	cpid
end

# get a unique choice point num
function nextchoicepointnum(gencontext::GeneratorContext)
	gencontext.numchoicepoints += 1
	gencontext.choicepointoffset + gencontext.numchoicepoints
end

# generate a unique rule name
uniquemethodname(rulename) = gensym(string(rulename))


# if node is a just rule name, convert it to a call to rule with no parameters
function convertrulenametorulecall(node, genrules::Vector{GeneratorRule})
	if isa(node, Symbol) && (node in map(genrule->genrule.rulename, genrules))
		return Expr(:call, node)	
	end
	node
end



# generic method for parsing node tree to identify and then transform particular types of function calls
# matchfn should return true if the desired type of function call is identified
# transformfn should return the tree to replace the node containing the call
# note: transformfn must handle recursively checking any nodes in its argument list itself (which is why matchfn is passed)
function transformfunccall(node, genrules::Vector{GeneratorRule}, gencontext::GeneratorContext, matchfn::Function, transformfn::Function)
	
	if islinenode(node)
		return node
	end

	# if node is a reference to an explicit DataGenerator method, then don't transform and go no deeper
	if (typeof(node) == Expr) && (node.head == Symbol(".")) && (node.args[1] == THIS_MODULE)
		return node
	end

	callname, callparams = extractfunccall(node)

	if (callname != nothing) && matchfn(callname, callparams, gencontext)
		return transformfn(callname, callparams, genrules, gencontext, matchfn, transformfn)
	end

	if typeof(node) == Expr
		node.args = map(arg -> transformfunccall(arg, genrules, gencontext, matchfn, transformfn), node.args)
		return node
	end
	
	return node

end


# process a param that should be a specified literal datatype or an expression
# note: cannot simply check for Expr or not since call to GT-specific no-arg func would be non-Expr but is non-literal
function processpossiblyliteralparam(param, datatype, gencontext::GeneratorContext)
	value = param
	paramisliteral = true
	try
		value = convert(datatype, param) # see if value can be interpreted as a literal of specified datatype
	catch
		paramisliteral = false # assume instead is not a literal
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
	if typeof(argexpr) == Expr
		filteredargs = removelinenodes(argexpr.args)
		if (argexpr.head == :(::)) && (length(filteredargs) == 2)
			return extractparamfromarg(filteredargs[1])
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

# attempt to convert to DataType (otherwise returns nothing)
function converttodatatype(s)
	datatype = nothing
	if (typeof(s) == Symbol) || ((typeof(s) == Expr) && (s.head == :curly))
		# :curly expression for Union{...}, Vector{...} etc.
		try
			datatype = eval(s)
			# TODO could eval perform side-effects here? should be OK when we know it is a symbol, but what about curly expression?
		catch
			datatype = nothing
		end
		if !(typeof(datatype) <: Type) # Type rather than datatype as Union{} is a subtype of Type, but not a DataType
			datatype = nothing
		end
	end
	datatype
end


# test whether syntax tree node in an expression is a line node (i.e. a file and line location)
# (as of v0.3, LineNumberNode does not seem to occur)
islinenode(node) = ((typeof(node) == Expr) && (node.head == :line)) || (typeof(node) == LineNumberNode)


# remove nodes in array that are line nodes
removelinenodes(args) = filter(arg->!islinenode(arg),args)


# extract method signature into tuple (name, arguments)
# (1) standard long or short form: foo(bar) or foo(bar) = 
# (2) GT-specific no args form: foo (but only when allownoparenthesisform is true)
function extractfuncsig(node, allownoparenthesisform = false)
	if typeof(node) == Expr
		if node.head == :call # standard long or short form
			callargs = removelinenodes(node.args)
			if length(callargs) >= 1
				return (callargs[1], callargs[2:end])
			end
		end
	elseif allownoparenthesisform && (typeof(node) == Symbol) # GT-specific no parenthesis form when no args
		return (node, [])
	end
	return (nothing,nothing)
end


# extract function definition into tuple (name, arguments, body)
# (1) long form: function foo(bar) ... end
# (2) short form: foo(bar) = ... 
# (3) GT-specific no args form: foo = ... (but only when allownoparenthesisform is true)
function extractfuncdef(node, allownoparenthesisform = false)
	if typeof(node) == Expr
		if (node.head == :function) || (node.head == :(=) )
			eqargs = removelinenodes(node.args)
			if length(eqargs) == 2
				(name, args) = extractfuncsig(eqargs[1], allownoparenthesisform)
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
# (2) GT-specific no args form: foo (but only when allownoparenthesisform is true)
function extractfunccall(node, allownoparenthesisform = false)
	if typeof(node) == Expr
		if node.head == :call # standard long or short form
			callargs = removelinenodes(node.args)
			if length(callargs) >= 1
				return (callargs[1], callargs[2:end])
			end
		end
	elseif allownoparenthesisform && (typeof(node) == Symbol)
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


# parses rule sources (as returned by translator) and appends them generator rules
function addrulesources(genrules::Vector{GeneratorRule}, rulesources::Vector{DataGeneratorTranslators.RuleSource})
	for rulesource in rulesources
		genrule = GeneratorRule(rulesource.rulename, rulesource.args, parse(join(rulesource.source, "\n")))
		push!(genrules, genrule)
	end
end


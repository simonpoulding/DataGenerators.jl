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
	metadata, generatorrules = extractmetadataandrules(genbody)

	# rewrite rules as functions and transform constructs
	gencontext = GeneratorContext(genname, subgenargs)
	transformrules!(generatorrules, gencontext)

	# construct and return code for generator type and methods that implement the rules
	typeblock = constructtype(genname, subgenargs, metadata, gencontext)
	methodsblock = constructmethods(generatorrules)

	esc(mergeexprs(typeblock, methodsblock))
	
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
			evalfn::Function

			function $(genname)(subgens::Vector = [])
				if length(subgens) != $(length(subgenargs))
					error("Incorrect number of sub generators $(length(subgens))")
				end

				if !all([typeof(sg) <: $(THIS_MODULE).Generator for sg in subgens])
					error("Not all subgenerators are of type $(THIS_MODULE).Generator $(subgens)")
				end
				new($metaInfo, $(gencontext.choicepointinfo), $(gencontext.rulemethodnames), subgens,
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


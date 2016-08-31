function transform_type_ast(ast::ASTNode)
	# consolidate typevar so that one exists as root of the child for each unique typevar
	process_type_consolidate_typevar_nodes(ast, ast)
	# handle Arrays
	process_type_array_nodes(ast)	# TODO: extend to AbstractArray
	# find datatypes node referring to abstract datatype
	process_type_abstract_datatypes(ast)
	# process abstract datatypes and typevars to add supported concrete types
	process_type_abstract_types(ast)
  	# add start node as reference to root to enable reachability check
  	push!(ast.refs, ast.children[1])
end


#TODO process non-concrete types (NB parameterised types can be abstract)
#TODO process composites (use constructors?)
# NB when defining parameterized types, can explicit paramters such as use Point{Float64}(1,2)
# parameterised types are not co-variant, but Tuples are!


# TypeVars are moved to be a child of the root node, and replaced with a reference in their original location in the AST
# If the TypeVar is used in multiple places ('bound'), then the typevar occurs only once as a child of the root, and all
# references refer to this same child: this ensures only one set of generator rules is generated for the typevar.
function process_type_consolidate_typevar_nodes(parentnode::ASTNode, rootnode::ASTNode)
	for idx in 1:length(parentnode.children)
		node = parentnode.children[idx]
		process_type_consolidate_typevar_nodes(node, rootnode)
		if node.func == :typevar
			# move the node a child of the root where we share it using references
			# is there already a child of the root for the same TypeVar, then simply re-use the existing one
			reftarget = nothing
			for rootchild in rootnode.children
				if (rootchild.func == :typevar) && (rootchild.args[:typevar] == node.args[:typevar])
					reftarget = rootchild
					break
				end
			end
			if reftarget == nothing
				# denormalise some typevar info the node itself as this may be transformed itself
				node.args[:ub] = node.args[:typevar].ub
				node.args[:lb] = node.args[:typevar].lb
				node.args[:numrefs] = 0
				push!(rootnode.children, node)
				reftarget = node
			end
			reftarget.args[:numrefs] += 1
			# replace current node with reference to the typevar now stored at root
			newrefnode = ASTNode(:typevarref)
			push!(newrefnode.refs, reftarget)
			parentnode.children[idx] = newrefnode
		end
	end
end

#TODO how to do this for all Array types (subtypes of abstract array)?
function process_type_array_nodes(parentnode::ASTNode)
	for idx in 1:length(parentnode.children)
		node = parentnode.children[idx]
		process_type_array_nodes(node)
		if (node.func == :datatype) && (node.args[:datatype] <: Array)
			@assert length(node.children) == 2  "Expected Array datatype node in AST to have two children"
			if (node.children[2].func == :typevarref)
				# if the dimensions argument is a typevar, then set this typevar to show it returns the number of dimensions
				node.children[2].refs[1].func = :typevarndims # indicates that this typevar represent 
			end
		end
	end 
end

# TODO: concrete Union{}, Tuple{} and Array{} types may also be subtypes of Any
# but infinitely recursive: Array{Array{...Array{Int}...}}
# note: commented out version is VERY slow the first time it is called for Any (presumably has to compile a lot of code)
# instead, we abandon returning tree where supported leaf types are nodes, and instead simply return a list of of the supported
# leaf types: this enable us to simply return the constant when parameter is Any.
process_type_supported_subtypes(datatype::DataType) = filter(t->issubtype(t, datatype), TYPE_TRANSLATOR_SUPPORTED_SIMPLE_LEAF_TYPES)
# function process_type_supported_subtypes(datatype::DataType)
# 	if isleaftype(datatype)
# 		if datatype in TYPE_TRANSLATOR_SUPPORTED_SIMPLE_LEAF_TYPES
# 			return (datatype, [])
# 		else
# 			return nothing
# 		end
# 	else
# 		supportedsubtypeslist = []
# 		for st in subtypes(datatype)
# 			if st != Any # Any is subtype of itself
# 				supportedsubtypes = process_type_supported_subtypes(st)
# 				if supportedsubtypes != nothing
# 					push!(supportedsubtypeslist, supportedsubtypes)
# 				end
# 			end
# 		end
# 		if isempty(supportedsubtypeslist)
# 			return nothing
# 		else
# 			return (datatype, supportedsubtypeslist)
# 		end
# 	end
# end

function process_type_abstract_datatypes(parentnode::ASTNode)
	for idx in 1:length(parentnode.children)
		node = parentnode.children[idx]
		process_type_abstract_datatypes(node)
		if (node.func == :datatype) && !isleaftype(node.args[:datatype]) && isempty(node.children)
			# abstract datatypes are not leaf nodes (and for our purposes, do not have parameters: thus Array would not be an abstract datatype)
			node.func = :abstractdatatype
		end
	end 
end

function process_type_abstract_types(parentnode::ASTNode)
	for idx in 1:length(parentnode.children)
		node = parentnode.children[idx]
		process_type_abstract_types(node)
		if node.func in [:abstractdatatype, :typevar,]
			@assert isempty(node.children)
			# TODO: handle typevar lb
			node.children = map(process_type_supported_subtypes(node.func == :typevar ? node.args[:ub] : node.args[:datatype])) do subtype
				subtypenode = ASTNode(:datatype)
				subtypenode.args[:name] = subtype.name
				subtypenode.args[:datatype] = subtype 
				subtypenode
			end
		end
	end
end

function transform_type_ast(ast::ASTNode)

	supporteddatatypes = derive_supported_datatypes(ast.args[:datatypes], ast.args[:typevardatatypes])

	datatyperootnode = create_datatype_root_node(supporteddatatypes)
	unionnode = create_union_node()
	typerootnode = create_type_root_node(datatyperootnode, unionnode)
	typevarnode = create_typevar_node()
	ast.children = [typerootnode, typevarnode,]

	add_choose_child(ast)
	add_datatype_root_node_ref(ast, datatyperootnode)
	add_type_root_node_ref(ast, typerootnode)
	add_typevar_node_ref(ast, typevarnode)

  	push!(ast.refs, typerootnode) # add start node as reference to root to enable reachability check

end

function derive_supported_datatypes(datatypes, typevardatatypes)
	# supported dataypes are those specified in the type to generate for (except Any in upper bound of typevars)
	# plus those types that can be handled directly by the generator macro
	# and finally Type and Tuple as these are useful for handling method signatures
	merge_datatypes_up([datatypes; filter(bound -> bound != Any, typevardatatypes); GENERATOR_SUPPORTED_CHOOSE_TYPES; Type; Tuple;])
end

function create_type_root_node(datatyperootnode::ASTNode, unionnode::ASTNode)
	node = ASTNode(:typeroot)
	push!(node.children, datatyperootnode)
	push!(node.children, unionnode)
	node
end

function create_typevar_node()
	node = ASTNode(:typevar)
	node.args[:name] = :TypeVar
	node
end

function create_union_node()
	node = ASTNode(:union)
	node.args[:name] = :Union
	node
end

function create_datatype_root_node(supporteddatatypes::Vector{DataType}) 
	if Any in supporteddatatypes
		create_datatype_node(Any)
	else
		# a "dummy" Any node in the sense that not all genuine subtypes of Any are available
		node = ASTNode(:dt)
		node.args[:name] = Any.name.name
		node.args[:datatype] = Any
		node.args[:abstract] = true
		node.children = map(st->create_datatype_node(st, supporteddatatypes), supporteddatatypes)
		node
	end
end

function create_datatype_node(t::DataType, supporteddatatypes::Vector{DataType})
	primarydatatype = primary_datatype(t)
	primaryisabstract = is_abstract_type(primarydatatype)
	node = ASTNode(:dt)
	node.args[:name] = primarydatatype.name.name
	node.args[:datatype] = primarydatatype
	node.args[:abstract] = primaryisabstract
	if primaryisabstract
		node.children = map(st->create_datatype_node(st, supporteddatatypes), supportable_subtypes(primarydatatype))
	else
		if !(node.args[:datatype] in [GENERATOR_SUPPORTED_CHOOSE_TYPES; Tuple;])  # only look at constructor methods when the type is not handled directly

			node.children = map(cm->create_constructor_method_node(cm), partially_supported_constructor_methods(supporteddatatypes, primarydatatype))
			# - constructors methods are partially-supported if for all types required there is at least a subtype as a child of the All node
			# need to create own bound typevar state (which, for ease of use, might store only symbol)
			# need to convert parameters of concrete type to typevars, and then get an instance
			# if call, then need to observe how typevars as this is the number in the Array{}
			# will need to add type
			# add hard-coded knowledge about lower case versions, e.g. ntuple, tuple, symbol?
			# add hard-coded knowledge about parse, convert
			# TODO Function
			# TODO Varargs
		end
	end
	node
end

function create_constructor_method_node(cm::Method)
	node = ASTNode(:cm)
	node.args[:method] = cm
	node
end

function add_choose_child(node::ASTNode)
	for child in node.children
		add_choose_child(child)
	end
	if (node.func == :dt)
		chooseablenodes = filter(child -> child.func == (node.args[:abstract] ? :dt : :cm), node.children)
		if !isempty(chooseablenodes)
			choosenode = ASTNode(:choose)
			for chooseablenode in chooseablenodes
				push!(choosenode.children, create_reference_node((node.args[:abstract] ? :dtref : :cmref), chooseablenode))
			end
			push!(node.children, choosenode)
		end
	end
end

function add_datatype_root_node_ref(node::ASTNode, datatyperootnode::ASTNode)
	for child in node.children
		add_datatype_root_node_ref(child, datatyperootnode)
	end
	if (node.func == :dt) && (node.args[:datatype] in [DataType; Union;])
		push!(node.children, create_reference_node(:datatyperootref, datatyperootnode))
	end
end

function add_type_root_node_ref(node::ASTNode, typerootnode::ASTNode)
	for child in node.children
		add_type_root_node_ref(child, typerootnode)
	end
	if (node.func in [:union, :typevar,]) || ((node.func == :dt) && (node.args[:datatype] in [Tuple;]))
		push!(node.children, create_reference_node(:typerootref, typerootnode))
	end
end

function add_typevar_node_ref(node::ASTNode, typevarnode::ASTNode)
	for child in node.children
		add_typevar_node_ref(child, typevarnode)
	end
	if (node.func in [:union, :dt,])
		push!(node.children, create_reference_node(:typevarref, typevarnode))
	end
end

function create_reference_node(func::Symbol, referencednode::ASTNode)
	node = ASTNode(func)
	push!(node.refs, referencednode)
	node
end



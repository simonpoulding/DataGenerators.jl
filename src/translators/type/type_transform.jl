
# non-abstract types that the generator can build special rules for generating instances
const TRANSLATOR_CONSTRUCTED_TYPES = [GENERATOR_SUPPORTED_CHOOSE_TYPES; Tuple; DataType; Union; TypeConstructor]

# returns only subtypes we can translate
# TODO (throughout) check which context should be used for this since generator is evaluated when the context of a module
function translatable_subtypes(dt::DataType)
	filter(subtypes(current_module(), dt)) do subdt
		!(subdt <: DataGenerators.Generator) &&
		Base.isexported(subdt.name.module, subdt.name.name)
	end
end


function transform_type_ast(ast::ASTNode)

	#DEBUG println("0: $([ast.args[:type]; ast.args[:supplementaltypes]])")
	# extract primary datatypes and upper bound datatypes of typevars in the parsed type as well as supplemental types
	supporteddts = extract_primary_datatypes([ast.args[:type]; ast.args[:supplementaltypes]])
	#DEBUG println("1: $(supporteddts)")
	# remove Any from this list (too big), and Vararg (handled in Tuple)
	supporteddts = filter(t -> !(t in [Any; Vararg;]), supporteddts)
	#DEBUG println("2: $(supporteddts)")
	# merge datatypes upwards (i.e. if A subsumes B, take just B)
	supporteddts = merge_datatypes_up(supporteddts)
	#DEBUG println("3: $(supporteddts)")
	# this now gives a non-overlapping list of the datatypes we will support in the dt tree
	if isempty(supporteddts)
		error("No supportable datatypes passed in type nor supplemental types")
	end

	if !all(t -> t in TRANSLATOR_CONSTRUCTED_TYPES, nonabstract_descendents(supporteddts; subtypefn=translatable_subtypes))
		# if some of the nonabstract descendent types of the supported types cannot be constructed directly 
		# then we add Tuple and Type as supported types in order to support the signatures of constructor methods
		supporteddts = merge_datatypes_up([supporteddts; Tuple; Type])
	end

	instancenode = create_instance_node()
	datatypenode = create_datatype_node()
	typenode = create_type_node()
	dtrootnode = create_dt_root_node(supporteddts)
	ast.children = [instancenode; datatypenode; typenode; dtrootnode;]

	add_reference(ast, :instanceref, instancenode) do node
		node.func == :cm
	end

	add_reference(ast, :datatyperef, datatypenode) do node
		(node.func == :instance) || 
		(node.func == :type)
	end

	add_reference(ast, :typeref, typenode) do node
		(node.func == :datatype) ||
		((node.func == :dt) && (node.args[:datatype] == Type))
	end

	add_reference(ast, :dtref, dtrootnode) do node
		(node.func == :instance) || 
		(node.func == :type)
	end

	add_choose(ast, :dt, :dtref) do node
		(node.func == :dt) && node.args[:abstract]
	end

	add_choose(ast, :cm, :cmref) do node
		(node.func == :dt) && !node.args[:abstract]
	end

  	push!(ast.refs, instancenode) # add type node as reference to root to enable reachability check

end

create_instance_node() = ASTNode(:instance)

create_datatype_node() = ASTNode(:datatype)

create_type_node() = ASTNode(:type)

function create_dt_root_node(supporteddts::Vector{DataType})
	# supporteddttree is the minimal partial subtree of primary datatypes that includes the supported datatypes, and remains
	# rooted at Any
	# the handlable_subtypes function filters the subtypes to those we can handle
	supporteddttree = datatype_tree(supporteddts; subtypefn = translatable_subtypes)
	create_dt_node(Any, supporteddttree, supporteddts)
end

function create_dt_node(t::DataType, supporteddttree::Dict{DataType, Vector{DataType}}, supporteddts::Vector{DataType})
	primarydatatype = primary_datatype(t)
	primaryisabstract = is_abstract(primarydatatype)
	node = ASTNode(:dt)
	node.args[:name] = primarydatatype.name.name
	node.args[:datatype] = primarydatatype
	node.args[:abstract] = primaryisabstract
	@assert primaryisabstract == !isempty(supporteddttree[primarydatatype])
	if primaryisabstract
		primarysubtypes = supporteddttree[primarydatatype]
		node.children = map(st->create_dt_node(st, supporteddttree, supporteddts), primarysubtypes)
	else 
		constructormethods = Vector{Union{Method, DataType}}()
		if !(primarydatatype in TRANSLATOR_CONSTRUCTED_TYPES) # TODO could also add partially supported constructor methods even in the case of a translator constructed alternative
			append!(constructormethods, partially_supported_constructor_methods(primarydatatype, supporteddts))
		end
		if isempty(constructormethods)
			push!(constructormethods, primarydatatype) 
		end
		node.children = map(cm->create_constructor_method_node(cm), constructormethods)
	end
	node
end

function create_constructor_method_node(cm::Method)
	node = ASTNode(:cm)
	node.args[:method] = cm
	node
end

function create_constructor_method_node(dt::DataType)
	node = ASTNode(:cm)
	node.args[:datatype] = dt
	node
end

function add_choose(predicate::Function, node::ASTNode, childfunc::Symbol, reffunc::Symbol)
	for child in node.children
		add_choose(predicate, child, childfunc, reffunc)
	end
	if predicate(node)
		chooseablenodes = filter(child -> child.func == childfunc, node.children)
		if !isempty(chooseablenodes)
			choosenode = ASTNode(:choose)
			for chooseablenode in chooseablenodes
				refnode = ASTNode(reffunc)
				refnode.refs = [chooseablenode;]
				push!(choosenode.children, refnode)
			end
			push!(node.children, choosenode)
		end
	end
end

function add_reference(predicate::Function, node::ASTNode, func::Symbol, target::ASTNode)
	for child in node.children
		add_reference(predicate, child, func, target)
	end
	if predicate(node)
		refnode = ASTNode(func)
		refnode.refs = [target;]
		push!(node.children, refnode)
	end
end


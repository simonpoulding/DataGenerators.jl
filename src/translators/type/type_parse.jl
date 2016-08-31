function parse_type(t::Type)
	node = ASTNode(:type)
	# rather fussily a :type node is the root; all other nodes in the tree (for the moment) are :datatype nodes
	# this root node (and its distinct handling) is mainly for consistency with other translators
	push!(node.children, parse_type_element(t))
	node
end

function parse_type_element(t)
	if isa(t, DataType)
		return parse_datatype(t)
	elseif isa(t, Union)
		return parse_union(t)
	elseif isa(t, TypeVar)
		return parse_typevar(t)
	else
		return parse_value(t)
	end
end

function parse_datatype(datatype::DataType)
	# we rely on the DataType type have the following fields:
	# name - the datatype's name
	# parameters - (SimpleVector of) arameters to the type
	# types ?
	node = ASTNode(:datatype)
	node.args[:name] = datatype.name # the 'outermost' datatype at this node (e.g. Array as the 'outermost' part of Array{Int64,2})
	node.args[:datatype] = datatype # full datatype represented by this node and its descendents (e.g. Array{Int64,2})
	node.children = map(t->parse_type_element(t), datatype.parameters)
	node
end

function parse_union(union::Union)
	node = ASTNode(:union)
	node.children = map(t->parse_type_element(t), union.types)
	node
end

function parse_typevar(typevar::TypeVar)
	node = ASTNode(:typevar)
	node.args[:name] = typevar.name
	node.args[:typevar] = typevar # need(??) to do this because typevar instances are shared between nodes when they refer to the same parameter
	node
end

function parse_value(value::Any)
	node = ASTNode(:value)
	node.args[:value] = value
	node
end
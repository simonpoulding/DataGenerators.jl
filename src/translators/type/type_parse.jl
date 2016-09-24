function parse_type(t::Type, supporteddts::Vector{DataType})
	node = ASTNode(:start)
	node.args[:type] = t
	node.args[:supporteddts] = supporteddts
	node
end

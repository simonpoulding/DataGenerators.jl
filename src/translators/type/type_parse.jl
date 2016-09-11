function parse_type(t::Type, supplementalts::Vector{Type})
	node = ASTNode(:start)
	node.args[:type] = t
	node.args[:supplementaltypes] = supplementalts
	node
end

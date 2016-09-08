function parse_type(t::Type)
	node = ASTNode(:type)
	node.args[:type] = t
	node.args[:datatypes], node.args[:typevardatatypes] = extract_primary_datatypes(t)
	node
end

using LightXML

#
# xsduri may URL as well as local file
#
function parse_xsd(xsduri)

	xsddoc = parse_file(xsduri)

	xsdroot = root(xsddoc)
	if name(xsdroot) != "schema"
		error("URI does not reference an XSD: the root is a not a schema element")
	end

	astroot = ASTNode(:xsd)

	if has_attribute(xsdroot, "targetNamespace")
		astroot.args[:targetNamespace] = attribute(xsdroot, "targetNamespace")
	end

	# TODO: LightXML does not currently have support for namespaces, so cannot retrieve additional namespace information

	parse_xsd_elements(xsdroot, astroot, xsduri)

	astroot

end

function parse_xsd_attribute(element::XMLElement, node::ASTNode, attributename)	
		if has_attribute(element, attributename)
 			node.args[symbol(attributename)] = attribute(element, attributename)
		end
end

function parse_xsd_elements(parentelement::XMLElement, parentnode::ASTNode, xsduri)

	for element in child_elements(parentelement)

		elementname = name(element)

		if elementname in ["element", "attribute", "group", "attributeGroup",
														"simpleType", "complexType",
														"simpleContent", "complexContent",
														"union", "restriction", "extension", "list",
														"all", "choice", "sequence",
														"enumeration", "pattern", "fractionDigits", "length", "maxExclusive", "maxInclusive",
															"maxLength", "minExclusive", "minInclusive", "minLength", "totalDigits","whiteSpace",
														"any", "anyAttribute"]

			node = ASTNode(symbol(elementname))

			if elementname in ["element", "attribute", "group", "attributeGroup", "simpleType", "complexType"]
				parse_xsd_attribute(element, node, "name")
			end

			if elementname in ["element"]
				parse_xsd_attribute(element, node, "abstract")
				parse_xsd_attribute(element, node, "substitutionGroup")
			end

			if elementname in ["element", "attribute", "group", "attributeGroup"]
				parse_xsd_attribute(element, node, "ref")
			end

			if elementname in ["element", "attribute"]
				parse_xsd_attribute(element, node, "type")
			end

			if elementname in ["element", "group", "all", "sequence", "choice"]
				parse_xsd_attribute(element, node, "minOccurs")
				parse_xsd_attribute(element, node, "maxOccurs")
			end

			if elementname in ["element", "attribute"]
				parse_xsd_attribute(element, node, "fixed")
			end

			if elementname in ["attribute"]
				parse_xsd_attribute(element, node, "use")
			end

			if elementname in ["complexType", "complexContent"]
				parse_xsd_attribute(element, node, "mixed")
			end

			if elementname in ["union"]
				parse_xsd_attribute(element, node, "memberTypes")
			end

			if elementname in ["restriction"]
				parse_xsd_attribute(element, node, "base")
			end

			if elementname in ["extension"]
				parse_xsd_attribute(element, node, "base")
			end

			if elementname in ["enumeration", "pattern", "fractionDigits", "length", "maxExclusive", "maxInclusive",
				"maxLength", "minExclusive", "minInclusive", "minLength", "totalDigits","whiteSpace"]
				parse_xsd_attribute(element, node, "value")
			end

			if elementname in ["list"]
				parse_xsd_attribute(element, node, "itemType")
			end

			if elementname in ["any", "anyAttribute"]
				parse_xsd_attribute(element, node, "namespace")
			end

			srcelement = new_element(elementname)
			set_attributes(srcelement, attributes_dict(element))
			node.source = split(string(srcelement),'\n')

			push!(parentnode.children, node)

			parse_xsd_elements(element, node, xsduri)

		elseif elementname == "annotation"

			parentnode.source = [parentnode.source; split(string(element),'\n')]

		elseif elementname == "include"

			schemalocation = attribute(element, "schemaLocation")

			# Some simple logic regarding absolute and relative URIs
			# But needs to be improved (perhaps URIParser package etc.)

			newslashpos = rsearch(schemalocation,'/')
			if newslashpos > 0
				# assume absolute
				newxsduri = schemalocation
			else
				# assume relative
				oldslashpos = rsearch(xsduri,'/')
				if oldslashpos == 0
					includexsduri = schemalocation
				else
					includexsduri = xsduri[1:oldslashpos] * schemalocation
				end
			end

			info("including schema from $includexsduri")

			# parse new URI
			includedastroot = parse_xsd(includexsduri)

			# include all elements from under root in the AST
			parentnode.children = [parentnode.children; includedastroot.children]

		else

			error("Do not know how to process XSD element $(elementname)")

		end

	end

end

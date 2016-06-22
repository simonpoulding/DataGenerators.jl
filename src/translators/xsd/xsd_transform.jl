# TODO:
# (1) Is the mixed attribute handled correctly? Should it propogate 'into' groups, sequence etc.?

function transform_xsd_ast(ast::ASTNode, startelement)

  elementglobaldefs = Dict{AbstractString,ASTNode}()
  substitutiongroups = Dict{AbstractString,Array{AbstractString}}()
  substitutiongroupdefs = Dict{AbstractString,ASTNode}()
  attributeglobaldefs = Dict{AbstractString,ASTNode}()
  groupglobaldefs = Dict{AbstractString,ASTNode}()
  attributegroupglobaldefs = Dict{AbstractString,ASTNode}()
  typeglobaldefs = Dict{AbstractString,ASTNode}()

  process_xsd_element_nodes(ast, elementglobaldefs, substitutiongroups)
  process_xsd_attribute_nodes(ast, attributeglobaldefs)
  process_xsd_group_nodes(ast, groupglobaldefs)
  process_xsd_attributegroup_nodes(ast, attributegroupglobaldefs)
  process_xsd_simpletype_nodes(ast, typeglobaldefs)
  process_xsd_complextype_nodes(ast, typeglobaldefs)

  process_xsd_mixed_arg(ast)
	
  process_xsd_occurs_args(ast)
  process_xsd_use_arg(ast)

  process_xsd_compositor_nodes(ast)
  process_xsd_extension_nodes(ast)
  process_xsd_restriction_nodes(ast)
  process_xsd_union_nodes(ast)
  process_xsd_list_nodes(ast)

  process_xsd_any_nodes(ast)
  process_xsd_anyattribute_nodes(ast)

  process_xsd_substitution_groups(ast, substitutiongroups, substitutiongroupdefs)
  process_xsd_element_refs(ast, elementglobaldefs, substitutiongroupdefs)
  process_xsd_attribute_refs(ast, attributeglobaldefs)
  process_xsd_group_refs(ast, groupglobaldefs)
  process_xsd_attributegroup_refs(ast, attributegroupglobaldefs)
  process_xsd_type_refs(ast, ast, typeglobaldefs)

  if haskey(elementglobaldefs,startelement)
    push!(ast.refs, elementglobaldefs[startelement])
  else
    error("start element $(startelement) is not globally defined")
  end

end

# TODO:
#   fixed element/attribute content

# TODO - currently LightXML doesn't allow us to process namespace definitions, so
# we make the assumption that xs: is the prefix for XML Schema, and any other prefix
# is that of the target namespace

process_xsd_is_builtin_type(typename) = startswith(typename,"xs:") # TODO parameterise xs namespace

# assume any prefix other than xs: is that of the target namespace, remove it
function process_xsd_handle_namespace(fullname)
  shortname = fullname
  if !process_xsd_is_builtin_type(fullname)
    splitnames = split(fullname,":")
    shortname = splitnames[end]
  end
  shortname
end


function process_xsd_element_nodes(parentnode::ASTNode, elementglobaldefs, substitutiongroups)

  for node in parentnode.children

    if node.func == :element

      if haskey(node.args, :ref)

        node.func = :elementRef

      else

        if parentnode.func == :xsd

          elementname = node.args[:name]
          elementglobaldefs[elementname] = node

          if !haskey(substitutiongroups, elementname)
            substitutiongroups[elementname] = AbstractString[]
          end
          if !(haskey(node.args, :abstract) && (node.args[:abstract]=="true"))
            push!(substitutiongroups[elementname], elementname)
          end

          if haskey(node.args, :substitutionGroup)

            substitutiongroupname = process_xsd_handle_namespace(node.args[:substitutionGroup])

            if !haskey(substitutiongroups, substitutiongroupname )
              substitutiongroups[substitutiongroupname] = AbstractString[]
            end
            push!(substitutiongroups[substitutiongroupname], elementname)

            if substitutiongroupname != elementname
              # if no type specification, then must be the same type as the head of the substitution group
              if !haskey(node.args, :type) && isempty(node.children)
                elementsubnode = ASTNode(:elementSub)
                elementsubnode.args[:ref] = substitutiongroupname
                push!(node.children, elementsubnode)
              end
            end

          end

        end

        if haskey(node.args, :type)
          typerefnode = ASTNode(:typeRef)
          typerefnode.args[:ref] = node.args[:type]
          insert!(node.children, 1, typerefnode)
        end

        if haskey(node.args, :fixed)
          warn(node, "currently do not handle fixed attribute")
        end

      end

    end

    process_xsd_element_nodes(node, elementglobaldefs, substitutiongroups)

  end

end


function process_xsd_attribute_nodes(parentnode::ASTNode, attributeglobaldefs)

  for node in parentnode.children

    if node.func == :attribute

      if haskey(node.args, :ref)

        node.func = :attributeRef

      else

        if parentnode.func == :xsd
          attributeglobaldefs[node.args[:name]] = node
        end

        if haskey(node.args, :type)
          typerefnode = ASTNode(:typeRef)
          typerefnode.args[:ref] = node.args[:type]
          insert!(node.children, 1, typerefnode)
        end

        if isempty(node.children)
          warn(node, "No type found for attribute, so assuming xs:string")
          typerefnode = ASTNode(:typeRef)
          typerefnode.args[:ref] = "xs:string"
          insert!(node.children, 1, typerefnode)
        end

        if haskey(node.args, :fixed)
          warn(node, "currently do not handle fixed attribute")
        end

      end

    end

    process_xsd_attribute_nodes(node, attributeglobaldefs)

  end

end


function process_xsd_group_nodes(parentnode::ASTNode, groupglobaldefs)

  for node in parentnode.children

    if node.func == :group

      if parentnode.func == :xsd

        node.func = :group
        # TODO could check for name existence and uniqueness - but currently assume valid XSD
        groupglobaldefs[node.args[:name]] = node

      else

        node.func = :groupRef

      end

    end

    process_xsd_group_nodes(node, groupglobaldefs)

  end

end


function process_xsd_attributegroup_nodes(parentnode::ASTNode, attributegroupglobaldefs)

  for node in parentnode.children

    if node.func == :attributeGroup

      if parentnode.func == :xsd

        node.func = :attributeGroup
        # TODO could check for name existence and uniqueness - but currently assume valid XSD
        attributegroupglobaldefs[node.args[:name]] = node

      else

        node.func = :attributeGroupRef

      end

    end

    process_xsd_attributegroup_nodes(node, attributegroupglobaldefs)

  end

end


function process_xsd_simpletype_nodes(parentnode::ASTNode, typeglobaldefs)

  for node in parentnode.children

    if node.func == :simpleType

      if parentnode.func == :xsd

        # TODO could check for name existence and uniqueness - but currently assume valid XSD
        typeglobaldefs[node.args[:name]] = node

      end

    end

    process_xsd_simpletype_nodes(node, typeglobaldefs)

  end

end


function process_xsd_complextype_nodes(parentnode::ASTNode, typeglobaldefs)

  for node in parentnode.children

    if node.func == :complexType

      if parentnode.func == :xsd

        typeglobaldefs[node.args[:name]] = node

      end

    end

    process_xsd_complextype_nodes(node, typeglobaldefs)

  end

end



function process_xsd_compositor_nodes(parentnode::ASTNode)

  # TODO handling of choice and group - does choice apply within a referenced group (I think not)?

  for node in parentnode.children

    if node.func in [:sequence, :choice, :all]

      # TODO: not all/choice/sequence when within group (but defaulting of occurs is sufficient)
      # TODO: any

      if node.func==:all

        warn(node, "treating all node as a sequence")
        node.func = :sequence

      end

    end

    process_xsd_compositor_nodes(node)

  end

end


function process_xsd_substitution_groups(ast::ASTNode, substitutiongroups, substitutiongroupdefs)

  for substitutiongroup in substitutiongroups

    substitutiongroupname = substitutiongroup[1]
    elementnames = substitutiongroup[2]

    if !((length(elementnames)==1) && (substitutiongroupname==elementnames[1]))

      substitutiongroupnode = ASTNode(:substitutionGroup)
      substitutiongroupnode.args[:name] = substitutiongroupname

      for elementname in elementnames

        elementrefnode = ASTNode(:elementRef)
        elementrefnode.args[:ref] = elementname
        if elementname==substitutiongroup[1]
          elementrefnode.args[:allowsubstitutiongroup] = false
        end
        push!(substitutiongroupnode.children, elementrefnode)

      end

      if isempty(elementnames)
        warn(node, "substitution group $(substitutiongroupname) has no concrete elements")
      end

      push!(ast.children, substitutiongroupnode)

      substitutiongroupdefs[substitutiongroupname] = substitutiongroupnode

    end

  end

end


function process_xsd_element_refs(parentnode::ASTNode, elementglobaldefs, substitutiongroupdefs)

  for node in parentnode.children

    if node.func in [:elementRef, :elementSub]

      ref = node.args[:ref]
      ref = process_xsd_handle_namespace(ref)

      if (node.func==:elementRef) && haskey(substitutiongroupdefs, ref) && !(haskey(node.args, :allowsubstitutiongroup) && (node.args[:allowsubstitutiongroup]==false))
        push!(node.refs, substitutiongroupdefs[ref])
      elseif haskey(elementglobaldefs, ref)
        push!(node.refs, elementglobaldefs[ref])
      else
        error(node, "reference to an element, $(ref), that is not defined")
      end

    end

    process_xsd_element_refs(node, elementglobaldefs, substitutiongroupdefs)

  end

end


function process_xsd_attribute_refs(parentnode::ASTNode, attributeglobaldefs)

  for node in parentnode.children

    if node.func == :attributeRef

        ref = node.args[:ref]
        ref = process_xsd_handle_namespace(ref)
        if haskey(attributeglobaldefs, ref)
          push!(node.refs, attributeglobaldefs[ref])
        else
          error(node, "reference to an attribute, $(ref), that is not defined")
        end

    end

    process_xsd_attribute_refs(node, attributeglobaldefs)

  end

end


function process_xsd_group_refs(parentnode::ASTNode, groupglobaldefs)

  for node in parentnode.children

    if node.func == :groupRef

        ref = node.args[:ref]
        ref = process_xsd_handle_namespace(ref)
        if haskey(groupglobaldefs, ref)
          push!(node.refs, groupglobaldefs[ref])
        else
          error(node, "reference to a group, $(ref), that is not defined")
        end

    end

    process_xsd_group_refs(node, groupglobaldefs)

  end

end


function process_xsd_attributegroup_refs(parentnode::ASTNode, attributegroupglobaldefs)

  for node in parentnode.children

    if node.func == :attributeGroupRef

        ref = node.args[:ref]
        ref = process_xsd_handle_namespace(ref)
        if haskey(attributegroupglobaldefs, ref)
          push!(node.refs, attributegroupglobaldefs[ref])
        else
          error(node, "reference to an attribute group, $(ref), that is not defined")
        end

    end

    process_xsd_attributegroup_refs(node, attributegroupglobaldefs)

  end

end


function process_xsd_type_refs(ast::ASTNode, parentnode::ASTNode, typeglobaldefs)

  # println("Processing node $(parentnode.func) $(haskey(parentnode.args,:name) ? parentnode.args[:name] : '-')")

  for node in parentnode.children

    typeref = ""
    if node.func in [:typeRef]
      typeref = node.args[:ref]
    elseif node.func in [:list]
      if haskey(node.args, :itemType)
        typeref = node.args[:itemType]
      end
    end


    if !isempty(typeref)

      typeref = process_xsd_handle_namespace(typeref)

      if haskey(typeglobaldefs, typeref)

          push!(node.refs, typeglobaldefs[typeref])

      elseif process_xsd_is_builtin_type(typeref)

          push!(node.refs, process_xsd_define_builtin_type(ast, typeglobaldefs, typeref))

      else

          error(node, "A $(node.func) node references a type, $(typeref), that is not defined")

      end

    end

    process_xsd_type_refs(ast, node, typeglobaldefs)

  end

end


function process_xsd_extension_nodes(parentnode::ASTNode)

  for node in parentnode.children

    if node.func==:extension

      if (parentnode.func==:complexContent) && haskey(parentnode.args, :mixed)
        warn(node, "In complex content derived by extension, the mixed attribute of the complex content or complex type element may not be honoured")
      end

      if haskey(node.args, :base)
        typerefnode = ASTNode(:typeRef)
        typerefnode.args[:ref] = node.args[:base]
        insert!(node.children, 1, typerefnode)
      end

    end

    process_xsd_extension_nodes(node)

  end

end


function process_xsd_restriction_nodes(parentnode::ASTNode)

  for node in parentnode.children

    if node.func==:restriction

      if parentnode.func == :complexContent

        warn(node, "Cannot process restriction to produce complex content: base type will be used unrestricted, and the mixed attribute is ignored")

        typerefnode = ASTNode(:typeRef)
        typerefnode.args[:ref] = node.args[:base]

        for child in node.children
          append!(node.source, child.source)
        end

        node.children = [typerefnode]

      else

        facetfuncs = [:enumeration, :pattern, :fractionDigits, :length, :maxExclusive, :maxInclusive, :maxLength, :minExclusive, :minInclusive, :minLength, :totalDigits, :whiteSpace]
        typefuncs = [:simpleType]

        facetchildren = filter(child->child.func in facetfuncs, node.children)
        typechildren = filter(child->child.func in typefuncs, node.children)
        otherchildren = filter(child->!(child.func in facetfuncs || child.func in typefuncs), node.children)

        facets = map(child->child.func, facetchildren)

        if isempty(facets)

          if haskey(node.args, :base)

            typerefnode = ASTNode(:typeRef)
            typerefnode.args[:ref] = node.args[:base]

            node.children = [typerefnode; otherchildren]

          end

        elseif all(facet->facet in [:enumeration, :pattern], facets)

          choicenode = ASTNode(:choice)
          choicenode.children = facetchildren

          for typechild in typechildren
            append!(node.source, typechild.source)
          end

          node.children = [choicenode; otherchildren]

          for facetchild in facetchildren
            if facetchild.func == :pattern
              if !haskey(node.args, :base) || (node.args[:base] != "xs:string")
                warn(facetchild, "restriction pattern applied to type other than xs:string - will ignore base type")
              end
            end
          end

        else

          if !isempty(typechildren)

            warn(node, "Cannot process restriction of local defined type with facets $(join(facets,",")) - locally defined type will be used unrestricted")

            for facetchild in facetchildren
              append!(node.source, facetchild.source)
            end

            node.children = [typechildren; otherchildren]

          else

            @assert haskey(node.args, :base)

            if process_xsd_is_builtin_type(node.args[:base])

              pattern = process_xsd_derive_builtin_pattern(node.args[:base], node, facetchildren)

              patternnode = ASTNode(:pattern)
              patternnode.args[:value] = pattern
              patternnode.children = (ASTNode)[]

              for facetchild in facetchildren
                append!(node.source, facetchild.source)
              end

              node.children = [patternnode; otherchildren]

            else

              warn(node, "Cannot process restriction of type $(node.args[:base]) with facets $(join(facets,",")) - base type will be used unrestricted")

              typerefnode = ASTNode(:typeRef)
              typerefnode.args[:ref] = node.args[:base]

              for facetchild in facetchildren
                append!(node.source, facetchild.source)
              end

              node.children = [typerefnode; otherchildren]

            end

          end

        end

      end

    end

    process_xsd_restriction_nodes(node)

  end

end


function process_xsd_union_nodes(parentnode::ASTNode)

  for node in parentnode.children

    if node.func==:union

      if haskey(node.args, :memberTypes)

        membertypes = split(node.args[:memberTypes], " ")
        for membertype in membertypes

          typerefnode = ASTNode(:typeRef)
          typerefnode.args[:ref] = membertype

          push!(node.children, typerefnode)

        end

      end

    end

    process_xsd_union_nodes(node)

  end

end


function process_xsd_list_nodes(parentnode::ASTNode)

  for node in parentnode.children

    if node.func==:list

      if haskey(node.args, :itemType)
        typerefnode = ASTNode(:typeRef)
        typerefnode.args[:ref] = node.args[:itemType]
        push!(node.children, typerefnode)
      end

    end

    process_xsd_list_nodes(node)

  end

end


function process_xsd_any_nodes(parentnode::ASTNode)

  for node in parentnode.children

    if node.func==:any

      warn(node, "Cannot currently process any node - nothing will be output")

    end

    process_xsd_any_nodes(node)

  end

end



function process_xsd_anyattribute_nodes(parentnode::ASTNode)

  for node in parentnode.children

    if node.func==:anyAttribute

      warn(node, "Cannot currently process anyattribute node - nothing will be output")

    end

    process_xsd_anyattribute_nodes(node)

  end

end


function process_xsd_derive_builtin_pattern(typename, node::ASTNode, facetnodes=(ASTNode)[])

  pattern = ""


	# TODO: *could* add whitespace around all datatypes since this *should* be stripped off by processing

	# For the string-derived classes, we try to use character classes where possible to permit easy transition to Unicode tokenspaces from the current ASCII
	# Note:
	# \c is XSD extension to regex character classes - name characters: letters, digits, plus hyphen, period, colon
	# \i is XSD extension to regex character classes - initial name characters: letters, plus hyphen

  if isempty(facetnodes) 
    if typename == "xs:string"
      pattern = ""		# interpreted by GT as a string of any valid characters, including CR/LF
    elseif typename == "xs:normalizedString"
      pattern = "" 		# serialisation space is the same as xs:string - the difference is the whitespace processing by the schema processor, not in the document itself
    elseif typename == "xs:token"
      pattern = "" 		# serialisation space is the same as xs:string - the difference is the whitespace processing by the schema processor, not in the document itself
    elseif typename == "xs:NMTOKEN"
      pattern = "\\c+"
    elseif typename == "xs:NMTOKENS"
      pattern = "\\c+(, \\c+)*"
    # elseif typename == "xs:Name"
    #   warn(node, "check pattern for built-in type $(typename)")
    #   pattern = "([A-Z]|[a-z]|[-:])+([A-Z]|[a-z]|[0-9]|[-:.])*" # TODO what other punctuation is allowed?
    elseif typename == "xs:NCName"
      pattern = "\\i\\c*"
    elseif typename == "xs:ID"
      warn(node, "uniqueness of xs:ID not enforced")
      pattern = "\\i\\c*"
    elseif typename == "xs:IDREF"
      warn(node, "existence of xs:IDREF not enforced")
      pattern = "\\i\\c*"
    elseif typename == "xs:decimal"
      pattern = "[+-]?([0-9]+|[0-9]*\.[0-9]+)" # TODO permits -0
    elseif typename == "xs:integer"
      pattern = "[+-]?[0-9]+"  # TODO permits -0
    elseif typename == "xs:positiveInteger"
      pattern = "\\+?0+[1-9][0-9]+"
    elseif typename == "xs:negativeInteger"
      pattern = "-?0+[1-9][0-9]+"
    elseif typename == "xs:nonPositiveInteger"
      pattern = "0|-0+[1-9][0-9]+"
    elseif typename == "xs:nonNegativeInteger"
      pattern = "\\+?[0-9]+"
    elseif typename == "xs:float"
      pattern = "[+-]?([0-9]+|[0-9]*\.[0-9]+)(E[+-]?[0-9]+)?|INF|-INF|NaN" # TODO not restricted to 32-bit float? permits E-0
    elseif typename == "xs:double"
      pattern = "[+-]?([0-9]+|[0-9]*\.[0-9]+)(E[+-]?[0-9]+)?|INF|-INF|NaN" # TODO not restricted to 64-bit float? permits E-0
    elseif typename == "xs:boolean"
      pattern = "true|false"
    elseif typename in ["xs:date","xs:time","xs:dateTime"]
      datepattern = "[+-]?([0-9]{4}-((01|03|05|07|08|10|12)-(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)-(0[1-9]|[1-2][0-9]|30)|02-(0[1-9]|1[0-9]|2[0-8]))|[0-9]{2}((1|3|5|7|9)(2|6)|(2|4|6|8)(0|4|8)|0(4|8))-02-29|((0|2|4|8)(0|4|8)|(1|3|5|7)(2|6))00-02-29)"
			timezonepattern = "(Z|[+-](0[0-9]|1[0-4]):[0-5][0-9])?"
			timepattern = "([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9](\\.[0-9]+)?"
			# TODO - this is very expensive in terms of choice points: consider using choose() from an appropriate datatype for this (and for numeric types) rather
			# than as a regex
			if typename == "xs:dateTime"
				pattern = datepattern * "T" * timepattern * timezonepattern
			elseif typename == "xs:date"
				pattern = datepattern * timezonepattern
			elseif typename == "xs:time"
				pattern = timepattern * timezonepattern
			end
		else
		  warn(node, "Do not know how to generate built-in type $(typename) - reverting to xs:string")
			pattern = process_xsd_derive_builtin_pattern("xs:string", node)
    end
	else
		# TODO - handle some facets
    warn(node, "Cannot process restriction of type $(typename) with facets $(join(map(child->child.func, facetchildren),",")) - base type will be used unrestricted")
		pattern = process_xsd_derive_builtin_pattern(typename, node)
  end

  pattern

end


function process_xsd_define_builtin_type(ast::ASTNode, typeglobaldefs, typename)

  simpletypenode = ASTNode(:simpleType)
  simpletypenode.args[:name] = typename

  pattern = process_xsd_derive_builtin_pattern(typename, simpletypenode)

  patternnode = ASTNode(:pattern)
  patternnode.args[:value] = pattern
  push!(simpletypenode.children, patternnode)

  push!(ast.children, simpletypenode)

  typeglobaldefs[typename] = simpletypenode

  simpletypenode

end



function process_xsd_occurs_args(parentnode::ASTNode)

  newchildren = ASTNode[]

  for node in parentnode.children

    newchild = node

    if (node.func in [:element, :elementRef, :all, :choice, :sequence, :typeRef, :any, :group]) && (parentnode.func != :xsd)

      lowerbound = 1
      if haskey(node.args, :minOccurs)
        lowerbound = parse(Int, node.args[:minOccurs])
      end

      upperbound = 1
      if haskey(node.args, :maxOccurs)
        if node.args[:maxOccurs] == "unbounded"
          upperbound = Inf
        else
          upperbound = parse(Int, node.args[:maxOccurs])
        end
      end

      if !((lowerbound==1) && (upperbound==1))
        quantifiernode = ASTNode(:quantifier)
        quantifiernode.children = [node]
        quantifiernode.args[:lowerbound] = lowerbound
        quantifiernode.args[:upperbound] = upperbound
        quantifiernode.source = node.source
        newchild = quantifiernode
      end

    end

    push!(newchildren, newchild)

    process_xsd_occurs_args(node)

  end

  parentnode.children = newchildren

end


function process_xsd_use_arg(parentnode::ASTNode)

  newchildren = ASTNode[]

  for node in parentnode.children

    newchild = node

    if (node.func in [:attribute, :attributeRef]) && (parentnode.func != :xsd)

			optional = true
      if haskey(node.args, :use)
        if node.args[:use] == "prohibited"
          node.func = :nothing
					optional = false
        elseif node.args[:use] == "required"
          optional = false
        end
      end

      if optional
        optionalnode = ASTNode(:optional)
        optionalnode.children = [node]
        optionalnode.source = node.source
        newchild = optionalnode
      end

    end

    push!(newchildren, newchild)

    process_xsd_use_arg(node)

  end

  parentnode.children = newchildren

end



function process_xsd_mixed_arg(parentnode::ASTNode)
  for node in parentnode.children
		if node.func in [:complexType]
			add_optional_text_nodes(node)
		end
    process_xsd_mixed_arg(node)
  end
end


function add_optional_text_nodes(node::ASTNode, parentmixedcontent=false, parentafterfirstelement=false)

	mixedcontent = parentmixedcontent
	afterfirstelement = parentafterfirstelement
	
	if (node.func in [:complexContent, :complexType]) && haskey(node.args, :mixed)
		mixedcontent = (node.args[:mixed] == "true")
	end

	# process children first so that we process elements (and groups) in physical order so that
	# we correctly detect the 'first' element in this mixed contentType subtree
  for child in node.children
    if child.func in [:sequence, :choice, :all, :complexType, :restriction, :extension]
		  afterfirstelement = add_optional_text_nodes(child, mixedcontent, afterfirstelement)
		end
	end
	
	if mixedcontent
		
    mixedchildren = (ASTNode)[]

    for child in node.children

      if child.func in [:element, :elementRef, :groupRef]		
				# if within this mixed contentType subtree we have not yet reached first element
				# then allow text before this first element as well as after
				if !afterfirstelement
          push!(mixedchildren, create_optional_text_node())						
					afterfirstelement = true
				end
        push!(mixedchildren, child)
        push!(mixedchildren, create_optional_text_node())
			else
        push!(mixedchildren, child)
      end

    end

    node.children = mixedchildren

  end

	afterfirstelement
	
end


function create_optional_text_node()
	textnode = ASTNode(:typeRef)
	textnode.args[:ref] = "xs:string"
	optionalnode = ASTNode(:optional)
	optionalnode.children = [textnode]
	optionalnode	
end

function build_xsd_rules(ast::ASTNode, rulenameprefix="")
    assign_rulenames(ast, rulenameprefix)
    rules = Vector{RuleSource}()
    build_xsd_lightxml_specific(rules)
    build_xsd_rule(ast, rules)
    rules
end

function build_xsd_rule(node::ASTNode, rules::Vector{RuleSource})

  if node.func in [:xsd]
    build_xsd_xsd(node, rules)
  elseif node.func in [:element]
    build_xsd_element(node, rules)
  elseif node.func in [:attribute]
    build_xsd_attribute(node, rules)
  elseif node.func in [:group, :attributeGroup, :complexType, :sequence, :extension]
    build_xsd_sequence(node, rules)
  elseif node.func in [:simpleType, :simpleContent, :complexContent, :restriction]
    build_xsd_call(node, rules)
  elseif node.func in [:pattern]
  build_xsd_pattern(node, rules)
  elseif node.func in [:choice, :substitutionGroup, :union]
    build_xsd_choice(node, rules)
  elseif node.func in [:quantifier]
    build_xsd_quantifier(node, rules)
  elseif node.func in [:optional]
    build_xsd_optional(node, rules)
  elseif node.func in [:enumeration]
    build_xsd_enumeration(node)
  elseif node.func in [:list]
    build_xsd_list(node, rules)
  elseif node.func in [:any, :anyAttribute, :nothing]
    build_xsd_nothing(node, rules)
  elseif node.func in [:elementRef, :elementSub, :typeRef, :attributeRef, :groupRef, :attributeGroupRef]
    # do nothing
    @assert isempty(node.children)
  else
    error("Unexpected xml node function $(node.func)")
  end

  for child in node.children
    build_xsd_rule(child, rules)
  end

end

# # isolates code that is specific to the XML package used to build the XML
function build_xsd_lightxml_specific(rules::Vector{RuleSource})
  rule = RuleSource(:construct_element, [:name, :content,])
	# push!(rule.source, "construct_element(name::AbstractString, content::Array{Any}) = begin")
	# TODO for the moment, remove typing on arguments to rule since this breaks under Julia 4.0
	push!(rule.source, "begin")
	push!(rule.source, "  xmlelement = new_element(name)")
	push!(rule.source, "  for item in content")
	push!(rule.source, "    if typeof(item) <: Tuple{AbstractString,Array}")
	# 	push!(rule.source, "    if typeof(item) <: Main.XMLElement")			# LightXML specific # TODO remove explicit Main. when GT support this properly
	# 	push!(rule.source, "      add_child(xmlelement, item)")			# LightXML specific
	push!(rule.source, "      add_child(xmlelement, construct_element(item[1], item[2]))")			# LightXML specific
	push!(rule.source, "    elseif typeof(item) <: Tuple{AbstractString,AbstractString}")
	push!(rule.source, "      set_attribute(xmlelement, item[1], item[2])")			# LightXML specific
	push!(rule.source, "    elseif typeof(item) <: AbstractString")
	push!(rule.source, "      add_text(xmlelement, item)")			# LightXML specific
	push!(rule.source, "    else")
	push!(rule.source, "      @assert false")
	push!(rule.source, "    end")
	push!(rule.source, "  end")
	push!(rule.source, "  xmlelement")
	push!(rule.source, "end")
  push!(rules, rule)
end


function build_xsd_xsd(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert length(node.refs)==1
  methodname = build_called_rulename(node)
  push!(rule.source, "  name, content = $(methodname)")
  push!(rule.source, "  construct_element(name, content)")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_element(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  build_xsd_sequence_body(node, rule)
	push!(rule.source, "  (\"$(escape_string(node.args[:name]))\", content)")
	# push!(rule.source, "  construct_element(\"$(escape_string(node.args[:name]))\", content)")
	# ... appear to need Main to be explicit when construct_element is defined outside of generator
  build_rule_end(rule, node)
  push!(rules, rule)
end


function build_xsd_attribute(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert length(node.children)==1
  methodname = build_called_rulename(node.children[1])
  push!(rule.source, "  content = $(methodname)")
  push!(rule.source, "  @assert typeof(content)<:AbstractString")
  push!(rule.source, "  (\"$(escape_string(node.args[:name]))\", content)")
  build_rule_end(rule, node)
  push!(rules, rule)
end


function build_xsd_sequence(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  build_xsd_sequence_body(node, rule)
  push!(rule.source, "  content")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_call(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert length(node.children)==1
  methodname = build_called_rulename(node.children[1])
  push!(rule.source, "  $(methodname)")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_pattern(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  push!(rule.source, "  choose(UTF8String, \"$(escape_string(node.args[:value]))\")")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_choice(node::ASTNode, rules::Vector{RuleSource})
  if isempty(node.children)
	  rule = build_rule_start(node)
    push!(rule.source, "  (Any)[]")
	  build_rule_end(rule, node)
    push!(rules, rule)
  else
    for child in node.children
		  rule = build_rule_start(node)
	    methodname = build_called_rulename(child)
	    push!(rule.source, "  $(methodname)")
		  build_rule_end(rule, node)
      push!(rules, rule)
		end
  end
end

function build_xsd_quantifier(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert haskey(node.args, :lowerbound)
  @assert haskey(node.args, :upperbound)
  @assert length(node.children)==1
  lowerbound = node.args[:lowerbound]
  upperbound = node.args[:upperbound]
  methodname = build_called_rulename(node.children[1])
	if (upperbound == Inf) || (lowerbound < upperbound)
		if (upperbound == Inf)
			push!(rule.source, "  r = reps($(methodname), $(lowerbound))")
		else
			push!(rule.source, "  r = reps($(methodname), $(lowerbound), $(upperbound))")
		end
	else
		push!(rule.source, "  r = [$(methodname)() for i in 1:$(lowerbound)]")
	end
  push!(rule.source, "  reduce((v,e)->[v; e], Any[], r)") # note: this flattens arrays in childcontent in a way that convert would not do
  build_rule_end(rule, node)
  push!(rules, rule)
end


function build_xsd_optional(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert length(node.children)==1
  methodname = build_called_rulename(node.children[1])
  push!(rule.source, "  choose(Bool) ? $(methodname) : Any[]")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_enumeration(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert haskey(node.args, :value)
  push!(rule.source, "  \"$(escape_string(node.args[:value]))\"")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_list(node::ASTNode)
  rule = build_rule_start(node)
  @assert length(node.children)==1
  methodname = build_called_rulename(node.children[1], rules::Vector{RuleSource})
  push!(rule.source, "  content = plus($(methodname))")
  push!(rule.source, "  join(content, \" \")")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_nothing(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  push!(rule.source, "  (Any)[]")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_xsd_sequence_body(parentnode::ASTNode, rule::RuleSource)
  push!(rule.source, "  content = (Any)[]")
  for node in parentnode.children
    methodname = build_called_rulename(node)
    if node.func in [:elementSub]
      push!(rule.source, "  childelement = $(methodname)")
      push!(rule.source, "  childcontent = childelement[2]")
    else
      push!(rule.source, "  childcontent = $(methodname)")
    end
    push!(rule.source, "  content = [content; childcontent]")  # note: this flattens arrays in childcontent in a way that push! would not do
  end
end

function build_bnf_rules(ast::ASTNode, addwhitespace::Bool, rulenameprefix="")
    assign_rulenames(ast, rulenameprefix)
    rules = Vector{RuleSource}()
    build_bnf_rule(ast, addwhitespace, rules)
    rules
end

function build_bnf_rule(node::ASTNode, addwhitespace, rules::Vector{RuleSource})

  # TODO: reduce number of rules, by not having separate ones for refs and literals? - have own bnf_build_rulename?
  # TODO: could also collapse RHS "choice" into LHS "variable def" during transform?
  if node.func in [:bnf]
	  build_bnf_call(node, rules)
  elseif node.func in [:variabledef]
	  build_bnf_variable(node, rules)
  elseif node.func in [:variableref]
	  # do nothing - we handle this directly in calling node
  elseif node.func in [:concatenation]
	  build_bnf_concatenation(node, addwhitespace, rules)
  elseif node.func in [:alternation]
	  build_bnf_alternation(node, rules)
  elseif node.func in [:optional]
	  build_bnf_optional(node, rules)
  elseif node.func in [:quantifier]
	  build_bnf_quantifier(node, addwhitespace, rules)
  elseif node.func in [:literal]
	  # do nothing - we handle this directly in calling node
  elseif node.func in [:regexp]
	  build_bnf_regexp(node, rules)
  elseif node.func in [:negation]
	  build_bnf_negation(node, rules)
  else
	  error("Unexpected bnf node with function $(node.func)")
  end

  for child in node.children
	  build_bnf_rule(child, addwhitespace, rules)
  end

end

function build_bnf_call(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_shortform_start(node)
  @assert length(node.refs)==1
  methodname = build_bnf_called_rulename(node.refs[1])
  push!(rule.source, "$(methodname)")
  build_rule_shortform_end(rule, node)
  push!(rules, rule)
end

function build_bnf_variable(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_shortform_start(node)
  @assert length(node.children)==1
  methodname = build_bnf_called_rulename(node.children[1])
  push!(rule.source, "$(methodname)")
  build_rule_shortform_end(rule, node)
  push!(rules, rule)
end


function build_bnf_concatenation(node::ASTNode, addwhitespace, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  push!(rule.source, "  content = Any[]")
  for child in node.children
    methodname = build_bnf_called_rulename(child)
	push!(rule.source, "  push!(content, $(methodname))")
  end
  if addwhitespace
	  push!(rule.source, "  join(content, \" \")")
  else
	  push!(rule.source, "  join(content)")
  end
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_bnf_alternation(node::ASTNode, rules::Vector{RuleSource}) # this is handled using a rule choice
  for child in node.children
		rule = build_rule_shortform_start(node)
		methodname = build_bnf_called_rulename(child)
		push!(rule.source, "$(methodname)")
		build_rule_shortform_end(rule, node)
	  push!(rules, rule)
  end
end

function build_bnf_optional(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
    @assert length(node.children)==1
    methodname = build_bnf_called_rulename(node.children[1])
    push!(rule.source, "choose(Bool) ? $(methodname) : \"\"")
    build_rule_shortform_end(rule, node)
    push!(rules, rule)
end

function build_bnf_quantifier(node::ASTNode, addwhitespace, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
    @assert length(node.children)==1
    methodname = build_bnf_called_rulename(node.children[1])
    if addwhitespace
	    push!(rule.source, "join(reps($(methodname), $(node.args[:min])), \" \")")
    else
	    push!(rule.source, "join(reps($(methodname), $(node.args[:min])))")
    end
    build_rule_shortform_end(rule, node)
    push!(rules, rule)
end

function build_bnf_regexp(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
    push!(rule.source, "choose(UTF8String), \"$(escape_str(node.args[:value]))\"")
    build_rule_shortform_end(rule, node)
    push!(rules, rule)
end

function build_bnf_negation(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
	# currently do not handle: a space is output instead
    push!(rule.source, "\" \"")
    build_rule_shortform_end(rule, node)
    push!(rules, rule)
end

function build_bnf_called_rulename(node::ASTNode)
	if node.func == :literal
	    "\"$(escape_str(node.args[:value]))\""
	elseif node.func == :variableref
	   @assert length(node.refs)==1
	   build_called_rulename(node.refs[1])
	else
	   build_called_rulename(node)
	end
end

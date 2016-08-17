function build_regex_rules(ast::ASTNode, rulenameprefix="")
	assign_rulenames(ast, rulenameprefix)
    rules = Vector{RuleSource}()
    build_regex_methods(ast, rules)
    rules
end

function build_regex_methods(node::ASTNode, rules::Vector{RuleSource})

    if node.func in [:regex]
        build_regex_regex(node, rules)
    elseif node.func in [:or]
        build_regex_or(node, rules)
    elseif node.func in [:and]
        build_regex_and(node, rules)
    elseif node.func in [:quantifier]
        build_regex_quantifier(node, rules)
    elseif node.func in [:optional]
        build_regex_optional(node, rules)
    elseif node.func in [:bracket]
        build_regex_bracket(node, rules)
    elseif node.func in [:terminal]
        build_regex_terminal(node, rules)
    elseif node.func in [:range]
        # do nothing - handled by bracket
    else
	   error("Unexpected regex node with function $(node.func)")
    end

    for child in node.children
        build_regex_methods(child, rules)
    end

end

# "start" rule explicitly converts result to datatype
function build_regex_regex(node::ASTNode, rules::Vector{RuleSource})
    rule = build_method_shortform_start(node)
    calledrulename = build_called_rulename(node.refs[1])
    push!(rule.source, "convert($(node.args[:datatype]), $(calledrulename))")
    build_method_shortform_end(rule, node)
    push!(rules, rule)
end

# apply rule choice point to children
function build_regex_or(node::ASTNode, rules::Vector{RuleSource})
    for child in node.children
        rule = build_method_shortform_start(node)
        calledrulename = build_called_rulename(child)
        push!(rule.source, "$(calledrulename)")
        build_method_shortform_end(rule, node)
        push!(rules, rule)        
    end
end

# concenate results of calls to the children
function build_regex_and(node::ASTNode, rules::Vector{RuleSource})
    rule = build_method_shortform_start(node)
    push!(rule.source, "*(")
    for child in node.children
        calledrulename = build_called_rulename(child)
        push!(rule.source, "$(calledrulename),")
    end
    push!(rule.source, ")")
    build_method_shortform_end(rule, node)
    push!(rules, rule)        
end

# apply sequence choice point
function build_regex_quantifier(node::ASTNode, rules::Vector{RuleSource})
    rule = build_method_shortform_start(node)
    calledrulename = build_called_rulename(node.children[1])
    if node.args[:upperbound] >= typemax(Int)
        push!(rule.source, "join(reps($(calledrulename), $(node.args[:lowerbound])))")
    else
        push!(rule.source, "join(reps($(calledrulename), $(node.args[:lowerbound]), $(node.args[:upperbound])))")
    end
    build_method_shortform_end(rule, node)
    push!(rules, rule)        
end

# apply choose(Bool)
function build_regex_optional(node::ASTNode, rules::Vector{RuleSource})
    rule = build_method_shortform_start(node)
    calledrulename = build_called_rulename(node.children[1])
    push!(rule.source, "choose(Bool) ? $(calledrulename) : \"\"")
    build_method_shortform_end(rule, node)
    push!(rules, rule)        
end

# return constant value
function build_regex_terminal(node::ASTNode, rules::Vector{RuleSource})
    rule = build_method_shortform_start(node)
    push!(rule.source, "\"$(escape_string(node.args[:value]))\"")
    build_method_shortform_end(rule, node)
    push!(rules, rule)        
end

# use choose(Int) to choose uniformly across all possible ranges (which are the child nodes)
function build_regex_bracket(node::ASTNode, rules::Vector{RuleSource})
    
    rule = build_method_start(node)
    
    cardinality = 0
    for child in node.children
        range = child.args[:value]
        cardinality += length(range)
    end

    if cardinality == 0
        push!(rule.source, "  \"\"")
    else
        push!(rule.source, "  idx = choose(Int, 0, $(cardinality-1))")

        condsource = Vector{AbstractString}()

        range = node.children[1].args[:value]
        unshift!(condsource, "  $(range[1]) + idx")      
        offset = length(range)
        for i in 2:length(node.children)
            range = node.children[i].args[:value]
            unshift!(condsource, "  (idx >= $(offset)) ? $(range[1] - offset) + idx :")
            offset += length(range)
        end

        push!(rule.source, "  string(convert(Char, ")
        append!(rule.source, condsource)
        push!(rule.source, "  ))")

    end

    build_method_end(rule, node)
    push!(rules, rule)        

end
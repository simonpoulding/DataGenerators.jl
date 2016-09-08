type RuleSource
  rulename::Symbol
  args::Vector{Any}
  comments::Vector{AbstractString}
  source::Vector{AbstractString}
  function RuleSource(rulename::Symbol, args=Any[])
    new(rulename, args, Vector{AbstractString}[], Vector{AbstractString}[])
  end
end

function output_generator(io::IO, genname, description, rules::Vector{RuleSource})
  println(io, "@generator $(genname) begin")
  println(io)
  println(io, "generates: [\"$(description)\"]")
  println(io)
  for rule in rules
    output_rule(io, rule)
    println(io)
  end
  println(io, "end")
end

function output_rule(io::IO, rule::RuleSource)
  for comment in rule.comments
    println(io, "# $(comment)")
  end
  args = join(map(a->string(a), rule.args),", ")
  print(io, "$(rule.rulename)($(args)) = ")
  for sourceline in rule.source
    println(io, sourceline)
  end
end


function build_rule_start(node::ASTNode)
  rule = RuleSource(node.rulename)
  rule.comments = node.source
  push!(rule.source, "begin")
  for warning in node.warnings
    push!(rule.source, "  warn(\"$(warning) in $(node.rulename)\")")
  end
  rule
end

function build_rule_end(rule::RuleSource, node::ASTNode)
  push!(rule.source, "end")
end

function build_rule_shortform_start(node::ASTNode)
  if !isempty(node.warnings)
    rule = build_rule_start(node)
  else
    rule = RuleSource(node.rulename)
    rule.comments = node.source
  end
  rule
end

function build_rule_shortform_end(rule::RuleSource, node::ASTNode)
  if !isempty(node.warnings)
    build_rule_end(rule, node)
  end
end

function build_called_rulename(callnode::ASTNode)
  if isempty(callnode.refs)
    callnode.rulename
  else
    @assert length(callnode.refs)==1
    refnode = callnode.refs[1]
    refnode.rulename
  end
end

function build_called_child_rulename(node::ASTNode, func::Symbol)
    funcchildren = filter(child -> child.func == func, node.children)
    @assert length(funcchildren) == 1
    build_called_rulename(funcchildren[1])
end

escape_rule_name(name) = replace(name, r"[^a-zA-Z0-9]", "_")

function assign_rulenames(node::ASTNode, rulenameprefix="")
  rulename = escape_rule_name(rulenameprefix * (isempty(rulenameprefix) ? "" : " ") * describe_ast_node(node))
  if isempty(rulenameprefix)
    # special case: empty prefix at root node, so name this the "start" rule as it will be the entry point to the generator
    node.rulename = symbol("start")
  else
    node.rulename = symbol(rulename)
  end
  for enumchild in enumerate(node.children)
    assign_rulenames(enumchild[2], rulename * " $(enumchild[1])") # note we use "canonical" rulename rather than actual rule name used for this node as prefix to children
  end
end



type RuleSource
  rulename::Symbol
  comments::Vector{AbstractString}
  args::Any
  source::Vector{AbstractString}
  function RuleSource(rulename::Symbol)
    new(rulename, Vector{AbstractString}[], Vector{Any}(), Vector{AbstractString}[])
  end
end


function build_generator_start(io::IO, genname, description)
  println(io, "@generator $(genname) begin")
  println(io, "  generates: [\"$(description)\"]")
end

function build_generator_end(io::IO)
  println(io, "end")
end

function build_method_start(io::IO, node::ASTNode)
  for sourceline in node.source
    println(io, "# $(sourceline)")
  end
  println(io, "$(node.rulename) = begin")
  for warning in node.warnings
    println(io, "  warn(\"$(warning) in $(node.rulename)\")")
  end
end

function build_method_start(node::ASTNode)
  rule = RuleSource(node.rulename)
  rule.comments = node.source
  push!(rule.source, "begin")
  for warning in node.warnings
    push!(rule.source, "  warn(\"$(warning) in $(node.rulename)\")")
  end
  rule
end

function build_method_end(io::IO, node::ASTNode)
  println(io, "end")
end

function build_method_end(rule::RuleSource, node::ASTNode)
  push!(rule.source, "end")
end

function build_method_shortform_start(io::IO, node::ASTNode)
  if !isempty(node.warnings)
    build_method_start(io, node)
  else
      for sourceline in node.source
        println(io, "# $(sourceline)")
      end
      print(io, "$(node.rulename) = ")
  end
end

function build_method_shortform_start(node::ASTNode)
  if !isempty(node.warnings)
    rule = build_method_start(node)
  else
    rule = RuleSource(node.rulename)
    rule.comments = node.source
  end
  rule
end

function build_method_shortform_end(io::IO, node::ASTNode)
	println(io)
	if !isempty(node.warnings)
	 	build_method_end(io, node)
	end
end

function build_method_shortform_end(rule::RuleSource, node::ASTNode)
  if !isempty(node.warnings)
    build_method_end(rule, node)
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

escape_name(name) = replace(name, r"[^a-zA-Z0-9]", "_")

escape_str(str) = replace(replace(replace(str, "\\", "\\\\"),"\"","\\\""),"\$","\\\$")

function assign_rulenames(node::ASTNode, rulenameprefix="")
  rulename = escape_name(rulenameprefix * (isempty(rulenameprefix) ? "" : " ") * describe_ast_node(node))
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



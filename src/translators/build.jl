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
  println(io, "$(node.methodname) = begin")
  for warning in node.warnings
    println(io, "  warn(\"$(warning) in $(node.methodname)\")")
  end
end

function build_method_end(io::IO, node::ASTNode)
  println(io, "end")
end

function build_method_shortform_start(io::IO, node::ASTNode)
	if !isempty(node.warnings)
	 	build_method_start(io, node)
	else
	    for sourceline in node.source
	      println(io, "# $(sourceline)")
	    end
	    print(io, "$(node.methodname) = ")
	end
end

function build_method_shortform_end(io::IO, node::ASTNode)
	println(io)
	if !isempty(node.warnings)
	 	build_method_end(io, node)
	end
end

function build_called_methodname(callnode::ASTNode)
  if isempty(callnode.refs)
    callnode.methodname
  else
    @assert length(callnode.refs)==1
    refnode = callnode.refs[1]
    refnode.methodname
  end
end

escape_name(name) = replace(name, r"[^a-zA-Z0-9]", "_")

escape_str(str) = replace(replace(replace(str, "\\", "\\\\"),"\"","\\\""),"\$","\\\$")

function assign_methodnames(node::ASTNode, prefix="")
  node.methodname = escape_name(prefix * (isempty(prefix) ? "" : " ") * describe_ast_node(node))
  for enumchild in enumerate(node.children)
    assign_methodnames(enumchild[2], node.methodname * " $(enumchild[1])")
  end
end



function build_bnf_generator(io::IO, ast::ASTNode, genname, startvariable, addwhitespace)
	
	assign_rulenames(ast)

	build_generator_start(io, genname, "BNF starting with variable $(startvariable)")
	build_bnf_methods(io, ast, addwhitespace)
	build_generator_end(io)

end

function build_bnf_methods(io::IO, node::ASTNode, addwhitespace)

  # TODO: reduce number of rules, by not having separate ones for refs and literals? - have own bnf_build_methodname?
  # TODO: could also collapse RHS "choice" into LHS "variable def" during transform?
  if node.func in [:bnf]
	  build_bnf_call(io, node)
  elseif node.func in [:variabledef]
	  build_bnf_variable(io, node)
  elseif node.func in [:variableref]
	  # do nothing - we handle this directly in calling node
  elseif node.func in [:concatenation]
	  build_bnf_concatenation(io, node, addwhitespace)
  elseif node.func in [:alternation]
	  build_bnf_alternation(io, node)
  elseif node.func in [:optional]
	  build_bnf_optional(io, node)
  elseif node.func in [:quantifier]
	  build_bnf_quantifier(io, node, addwhitespace)
  elseif node.func in [:literal]
	  # do nothing - we handle this directly in calling node
  elseif node.func in [:regexp]
	  build_bnf_regexp(io, node)
  elseif node.func in [:negation]
	  build_bnf_negation(io, node)
  else
	  error("Unexpected bnf node with function $(node.func)")
  end

  for child in node.children
	  build_bnf_methods(io, child, addwhitespace)
  end

end

function build_bnf_call(io::IO, node::ASTNode)
  build_method_shortform_start(io, node)
  @assert length(node.refs)==1
  methodname = build_bnf_called_methodname(node.refs[1])
  print(io, "$(methodname)")
  build_method_shortform_end(io, node)
end

function build_bnf_variable(io::IO, node::ASTNode)
  build_method_shortform_start(io, node)
  @assert length(node.children)==1
  methodname = build_bnf_called_methodname(node.children[1])
  print(io, "$(methodname)")
  build_method_shortform_end(io, node)
end


function build_bnf_concatenation(io::IO, node::ASTNode, addwhitespace)
  build_method_start(io, node)
  println(io, "  content = Any[]")
  for child in node.children
    methodname = build_bnf_called_methodname(child)
	println(io, "  push!(content, $(methodname))")
  end
  if addwhitespace
	  println(io, "  join(content, \" \")")
  else
	  println(io, "  join(content)")
  end
  build_method_end(io, node)
end

function build_bnf_alternation(io::IO, node::ASTNode) # this is handled a rule choice
    for child in node.children
		build_method_shortform_start(io, node)
		methodname = build_bnf_called_methodname(child)
		print(io, "$(methodname)")
		build_method_shortform_end(io, node)
	end
end

function build_bnf_optional(io::IO, node::ASTNode)
    build_method_shortform_start(io, node)
    @assert length(node.children)==1
    methodname = build_bnf_called_methodname(node.children[1])
    print(io, "choose(Bool) ? $(methodname) : \"\"")
    build_method_shortform_end(io, node)
end

function build_bnf_quantifier(io::IO, node::ASTNode, addwhitespace)
    build_method_shortform_start(io, node)
    @assert length(node.children)==1
    methodname = build_bnf_called_methodname(node.children[1])
    if addwhitespace
	    print(io, "join(reps($(methodname), $(node.args[:min])), \" \")")
    else
	    print(io, "join(reps($(methodname), $(node.args[:min])))")
    end
    build_method_shortform_end(io, node)
end

function build_bnf_regexp(io::IO, node::ASTNode)
    build_method_shortform_start(io, node)
    print(io, "choose(UTF8String), \"$(escape_str(node.args[:value]))\"")
    build_method_shortform_end(io, node)
end

function build_bnf_negation(io::IO, node::ASTNode)
    build_method_shortform_start(io, node)
	# currently do not handle: a space is output instead
    print(io, "\" \"")
    build_method_shortform_end(io, node)
end

function build_bnf_called_methodname(node::ASTNode)
	if node.func == :literal
	    "\"$(escape_str(node.args[:value]))\""
	elseif node.func == :variableref
	    @assert length(node.refs)==1
		build_called_methodname(node.refs[1])
	else
	    build_called_methodname(node)
	end
end

function transform_regex_ast(ast::ASTNode)
  # flatten :or nodes with only child
  process_regex_or_nodes(ast)
  # flatten :and nodes with only child, and concatenate adjacent terminal children
  process_regex_and_nodes(ast)
  # add start node as reference to root to enable reachability check
  push!(ast.refs, ast.children[1])
end

function process_regex_or_nodes(parentnode::ASTNode)
  for idx in 1:length(parentnode.children)
    node = parentnode.children[idx]
    process_regex_or_nodes(node)
    if node.func == :or
      if length(node.children) == 1
        # flatten if a single child since no need for a choice
        parentnode.children[idx] = node.children[1]
      end
    end
  end
end

function process_regex_and_nodes(parentnode::ASTNode)
  for idx in 1:length(parentnode.children)
    node = parentnode.children[idx]
    process_regex_and_nodes(node)
    if node.func == :and
      # concatenate adjacent terminals
      i = 1
      while i < length(node.children)
        if (node.children[i].func == :terminal) && (node.children[i+1].func == :terminal)
          node.children[i].args[:value] *= node.children[i+1].args[:value]
          deleteat!(node.children, i+1)
        else
          i += 1 
        end
      end
      # flatten if a single child since no need for and rule
      if length(node.children) == 1
        parentnode.children[idx] = node.children[1]
      end
    end
  end
end
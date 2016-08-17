function transform_regex_ast(ast::ASTNode)
  # flatten :or nodes with only child
  process_regex_or_nodes(ast)
  # flatten :and nodes with only child
  process_regex_and_nodes(ast)
  # add start node as reference to root to enable reachability check
  push!(ast.refs, ast.children[1])
end

# TODO concatenate terminals under :and


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
      if length(node.children) == 1
        # flatten if a single child since no need for a choice
        parentnode.children[idx] = node.children[1]
      end
    end
  end
end
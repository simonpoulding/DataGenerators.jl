function transform_ast(ast::ASTNode)
  for ref in ast.refs
    analyse_reachability(ref)
  end
  discard_unreachable_children(ast)
  # order_children_by_references(ast)
end

function analyse_reachability(node::ASTNode)
  if !node.reachable
    node.reachable = true
    for child in node.children
      analyse_reachability(child)
    end
    for ref in node.refs
      analyse_reachability(ref)
    end
  end
end


function discard_unreachable_children(rootnode::ASTNode)
  reachablechildren = (ASTNode)[]
  for child in rootnode.children
    if child.reachable
      push!(reachablechildren, child)
    else
      warn("discarding unreachable subtree starting at node $(describe_ast_node(child))")
    end
  end
  rootnode.children = reachablechildren
end

function order_children_by_references(rootnode::ASTNode)

  orderedchildren = ASTNode[]
  workingchildren = ASTNode[]

  unsatisfiedcount = Dict{ASTNode,Int}()
  isreferencedby = Dict{ASTNode,Array{ASTNode}}()

  for child in rootnode.children
    isreferencedby[child] = (ASTNode)[]
  end

  for child in rootnode.children

    references = references_in_subtree(child)

    unsatisfiedcount[child] = length(references)
    if unsatisfiedcount[child] == 0
      push!(workingchildren, child)
    end

    for reference in references
      push!(isreferencedby[reference], child)
    end

  end

  while !isempty(workingchildren)

    workingchild = shift!(workingchildren)
    push!(orderedchildren, workingchild)

    for referencer in isreferencedby[workingchild]
      # @assert unsatisfiedcount[referencee] > 0
      unsatisfiedcount[referencer] -= 1
      if unsatisfiedcount[referencer] == 0
        push!(workingchildren, referencer)
      end
    end

  end

  if length(orderedchildren) < length(rootnode.children)
    for child in setdiff(rootnode.children, orderedchildren)
      println("$(describe_ast_node(child))) references:")
      references = references_in_subtree(child)
      for reference in references
          if !(reference in orderedchildren)
            println("    $(describe_ast_node(reference)))")
          end
      end
    end
    error("unable to order the children by reference - circular references?")
  end

  rootnode.children = orderedchildren

end

function references_in_subtree(node::ASTNode)
  unique([node.refs, foldr(vcat, ASTNode[], map(child->references_in_subtree(child), node.children) ) ])
  # can't use mapreduce since it requires a non-empty array
end

import Base.warn
function warn(node::ASTNode, msg)
  push!(node.warnings, msg)
  sourcetext = isempty(node.source) ? "" : " at source: " * join(node.source)
  warn("$(msg)$(sourcetext)")
end

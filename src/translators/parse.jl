type ASTNode
	func::Symbol
	children::Array{ASTNode}
	args::Dict{Symbol,Any}
	source::Array{AbstractString}
	refs::Array{ASTNode}
	warnings::Array{AbstractString}
	reachable::Bool
	methodname::AbstractString
end

function ASTNode(func::Symbol, children::Array{ASTNode} = (ASTNode)[], args::Dict{Symbol,Any} =  Dict{Symbol,Any}())
	ASTNode(func, children, args, (AbstractString)[], (ASTNode)[], (AbstractString)[], false, "")
end

describe_ast_node(node::ASTNode) = "$(node.func)" * (haskey(node.args,:name) ? " " * "$(node.args[:name])" : "")

import Base.show	
function show(io::IO, astnode::ASTNode, indent=0)
  indentstr = " "^indent
  print(io, "$(indentstr)$(astnode.func)")
  for arg in astnode.args
    if typeof(arg[2]) <: Array
      print(io, " $(arg[1])=>$(join(arg[2],","))")
    elseif typeof(arg[2]) <: OrdinalRange
      range = arg[2]
      print(io, " $(arg[1])=>$(range[1]):$(range[end])")
    else
      print(io, " $(arg[1])=>$(arg[2])")
    end
  end
  for sourceline in astnode.source
    print(io, " SOURCE: $(sourceline)")
  end
  for ref in astnode.refs
    print(io, " REF: $(describe_ast_node(ref))")  # avoids issues of circular references, and lengthy output
  end
  for warning in astnode.warnings
    print(io, " WARNING: $(warning)")
  end
  if (!astnode.reachable)
    print(io, " UNREACHABLE")
  end
  if !isempty(astnode.methodname)
    print(io, " GENNAME: $(astnode.methodname)")
  end
  println(io)
  for child in astnode.children
    show(io, child, indent+2)
  end
end
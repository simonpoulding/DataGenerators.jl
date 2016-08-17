type ASTNode
	func::Symbol
	children::Vector{ASTNode}
	args::Dict{Symbol,Any}
	source::Vector{AbstractString}
	refs::Vector{ASTNode}
	warnings::Vector{AbstractString}
	reachable::Bool
	rulename::Symbol
end

function ASTNode(func::Symbol, children::Array{ASTNode} = (ASTNode)[], args::Dict{Symbol,Any} = Dict{Symbol,Any}())
	ASTNode(func, children, args, (AbstractString)[], (ASTNode)[], (AbstractString)[], false, :unnamed)
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
  if astnode.rulename != :unnamed
    print(io, " RULENAME: $(astnode.rulename)")
  end
  println(io)
  for child in astnode.children
    show(io, child, indent+2)
  end
end
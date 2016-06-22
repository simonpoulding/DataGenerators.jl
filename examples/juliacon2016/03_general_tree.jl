# general tree generator
type TreeNode
	label::Any
	childnodes::Vector{TreeNode}
end

treesize(t::TreeNode) = isempty(t.childnodes) ? 1 : 1 + sum(map(c->treesize(c), t.childnodes))
treeheight(t::TreeNode) = isempty(t.childnodes) ? 0 : 1 + maximum(map(c->treeheight(c), t.childnodes))

import Base.show
function show(io::IO, t::TreeNode, indent=0)
	if indent==0
		println("Tree: ")
	end
	println(" "^indent, t.label)
	for c in t.childnodes
		show(io, c, indent+1)
	end
	if indent==0
		println()
		println("size: ", treesize(t), "; height: ", treeheight(t))
	end
end


using DataGenerators

@generator TreeGen begin
  start = treenode
  treenode = TreeNode(label, mult(treenode))
  label = choose(Int, 1, 9)
end

@generator EmailTreeGen begin
  start = treenode
  treenode = TreeNode(label, mult(treenode))
  label = choose(ASCIIString, "([a-z0-9]+\\.)*[a-z0-9]+@([a-z0-9]+\\.){1,2}[a-z0-9]+")
end


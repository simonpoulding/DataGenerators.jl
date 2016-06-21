# general tree generator
using DataGenerators

@generator GeneralTreeGen begin
  start = treenode
  treenode = (label, mult(treenode))
  label = choose(Int,1,9)
end

gn = GeneralTreeGen()



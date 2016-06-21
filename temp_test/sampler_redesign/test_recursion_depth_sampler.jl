# TODO:
#	- amendtrace
#	- test model building

println("START test_recursion_depth_sampler")

using Base.Test
using DataGenerators

# generator for arithmetic expressions
@generator RecursiveGen begin
  start = A
  A = (B, mult(A))
  B = :label 	# we use additional rule to test recursion counting by model when multiple rules exist
end

# generator
gn = RecursiveGen()

scm = SamplerChoiceModel(gn)

# check default model and get ids, etc required later

@assert length(scm.samplers) == 1
cpidmultA = first(keys(scm.samplers))
originalsampler = deepcopy(scm.samplers[cpidmultA])
@assert numparams(scm) == 1 # 3 categorical samplers, one with 4 choices, two with 2
@assert getparams(scm) == [0.5,]

#
# constructor
#
println("Testing constructor:")

# now make choice point a recursion depth sampler

scm.samplers[cpidmultA] = DataGenerators.RecursionDepthSampler(deepcopy(originalsampler), 10)
@test numparams(scm) == 10 # 10 samplers each with one parameter which duplicates parameter of base sampler
@test getparams(scm) == fill(0.5, 10)
@test paramranges(scm) == fill((0.0,1.0), 10)

scm.samplers[cpidmultA] = DataGenerators.RecursionDepthSampler(deepcopy(originalsampler), 4, Vector[[0.5,], [0.4], [0.3], [0.2]])
@test numparams(scm) == 4 # 4 samplers each with one parameter as specified in constructor
@test getparams(scm) == [0.5, 0.4, 0.3, 0.2]
@test paramranges(scm) == fill((0.0,1.0), 4)

scm.samplers[cpidmultA] = DataGenerators.RecursionDepthSampler(deepcopy(originalsampler), 4, Vector[[0.9], [0.8], [0.7]])
@test numparams(scm) == 4 # 4 samplers each with one parameter; last one is not specified and so should be that of the base sampler
@test getparams(scm) == [0.9, 0.8, 0.7, 0.5]
@test paramranges(scm) == fill((0.0,1.0), 4)


#
# setparams
#
println("Testing setparams:")

scm.samplers[cpidmultA] = DataGenerators.RecursionDepthSampler(deepcopy(originalsampler), 4)
newparams = [0.27, 0.84, 0.88, 0.49,]
setparams(scm, newparams)
@test getparams(scm) == newparams


#
# sample
#
println("Testing sample:")

treeheight(tree) = isempty(tree[2]) ? 0 : 1 + maximum(map(child->treeheight(child), tree[2])) # height of a single node subtree is 0
treesize(tree) = isempty(tree[2]) ? 1 : 1 + sum(map(child->treesize(child), tree[2])) # size of a single node subtree is 0

scm.samplers[cpidmultA] = DataGenerators.RecursionDepthSampler(deepcopy(originalsampler), 3, Vector[[0.5], [0.5], [1.0]])
# the parameters means that the root and first level child can produce children, but second level always has no children
# so height should never be more than two

samplesize = 1000
heights = Vector{Int}()
selectedtraces = Vector()
print("Sampling from model: ")
for s in 1:samplesize
	result, state = generate(gn, choicemodel=scm)
	print(".")
	height = treeheight(result)
	push!(heights, height)
	@test 0 <= height <= 2
	if height == 1
		push!(selectedtraces, state.cmtrace)
	end
end
println()
# at least some should heights should be 0, 1, and 2
@test any(h->h==0, heights) 
@test any(h->h==1, heights) 
@test any(h->h==2, heights) 


#
# estimateparams
#
println("Testing estimateparams:")

# since we restrict traces to heights of 1, new sample should never sample higher heights

estimateparams(scm, selectedtraces)

newsamplesize = 1000
newheights = Vector{Int}()
print("Sampling from re-estimated model: ")
for s in 1:newsamplesize
	result, state = generate(gn, choicemodel=scm)
	print(".")
	height = treeheight(result)
	push!(newheights, height)
	@test 0 <= height <= 1
end
println()
# at least some should heights should be 0, 1
@test any(h->h==0, newheights) 
@test any(h->h==1, newheights) 


#
# TODO amendtrace 
#
println("TODO Testing amendtrace:")

println("END test_recursion_depth_sampler")

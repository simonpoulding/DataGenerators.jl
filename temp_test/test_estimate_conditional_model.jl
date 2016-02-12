# TODO:
#	- proper test of nested conditional samplers
# 	- more explicitly test K2 calculation
#	- depths > 1
#	- test distinguish by recursion depth
#	- test recursion depth model building (or do in test_recursion_depth_sampler)
#	- test restrict to ancestors (or in test_restrict_ancestor)

println("START test_build_conditional_model")

using Base.Test
using GodelTest

# generator for arithmetic expressions
@generator ABCDGen begin
  start = S
  start = X
  S = A
  S = B
  S = C
  S = D
  A = "a" * X
  B = "b" * X
  C = "c" * X
  D = "d" * X
  X = "x"
  X = "y"
end

# generator
gn = ABCDGen()

scm = SamplerChoiceModel(gn)

# make all choice points conditional, but don't specify which parent
for cpid in keys(scm.samplers)
	if numparams(scm.samplers[cpid]) > 0 # no point making samplers without parameters conditional
		# scm.samplers[cpid] = GodelTest.ConditionalSampler(GodelTest.ConditionalSampler(scm.samplers[cpid]))
		scm.samplers[cpid] = GodelTest.ConditionalSampler(scm.samplers[cpid])
	end
end

samplesize = 10000
selectedtraces = Vector()
print("Sampling from model: ")
for s in 1:samplesize
	result, state = generate(gn, choicemodel=scm)
	print(".")
	if result in ("ax", "cy", "dx", "y")
		push!(selectedtraces, state.cmtrace)
	end
end
println()

println("Estimating conditional model...")
GodelTest.estimateconditionalmodel(scm, selectedtraces)

print("Sampling from estimated conditional model:")

newcounts = Dict("ax"=>0, "cy"=>0, "dx"=>0, "y"=>0)
# only ax, cy, dx, and y should be returned from re-estimated model
newsamplesize = 10000
for s in 1:newsamplesize
	result, state = generate(gn, choicemodel=scm)
	print(".")
	@test haskey(newcounts, result)  # checks that only the four valid outputs are returned
	newcounts[result] += 1
end
println()

@test newcounts["ax"] > 0
@test newcounts["cy"] > 0
@test newcounts["dx"] > 0
@test newcounts["y"] > 0

println("END test_build_conditional_model")


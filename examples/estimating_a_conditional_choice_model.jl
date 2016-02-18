# An example to showing how to specify a conditional model, and then estimate the conditional dependencies.
# Note: in this example, a single reestimation of the model is sufficient.  In other cases -- for example a 
# property such as the size of the output is optimised and results of this size are not immediately returned from
# the unconditional model -- an iterative EDA-like may be appropriate: at each iteration the traces of the results 
# "closest" to the target are used to restimate the model.

using GodelTest

# "toy" generator for building strings consisting of symbols a, b, c, d, x, and/or y
@generator CondExampleGen begin
  start = S
  S = A
  S = B
  S = C
  S = D
  A = "a" * XY
  B = "b" * XY
  C = "c" * XY
  D = "d" * XY
  XY = "x"
  XY = "y"
end

gn = CondExampleGen()

scm = SamplerChoiceModel(gn)

# now make all the choice points conditional by wrapping the choice point in a conditional sampler (could also be achieved
# by specifying a custom mapping function to the choice model constructor)
# note that we don't specify a parent here, so this means at this point the conditional sampler simply
# applies the underlying sampler, i.e. as if there were no conditionality
for cpid in keys(scm.samplers)
	if numparams(scm.samplers[cpid]) > 0 # no point making samplers without parameters conditional
		scm.samplers[cpid] = GodelTest.ConditionalSampler(scm.samplers[cpid])
	end
end

# pretty print the current choice model
println("Unconditional choice model: ")
println(scm)
println()

# first run the generator using the unconditional model: this permits all possible outputs of the 
# generator -- i.e. ax, ay, bx, by, cx, cy, dx, and dy -- to be returned
selectedtraces = Vector()
println("Sampling using unconditional choice model: ")
for s in 1:1000
	result, state = generate(gn, choicemodel=scm)
	print("$(result) ")
	# if output is what we want, then we store the trace returned in the state from the generate call
	# in this example, what we want are outputs of ax, cy, dx
	if result in ("ax", "cy", "dx")
		push!(selectedtraces, state.cmtrace)
	end
end
println()

# We use the selected traces to estimate the dependencies in the conditional model, and the conditional distributions
# at each choice point.
# For each choice point in the model, this method will identify any "parent" choice points where the value
# current choice point appears to depend on the most recent value returned by the parent choice point.
# It will then set the ConditionalSampler to make the choice point conditional on the identified parent,
# and then estimate the parameters of the underlying sampler (i.e. the original sampler in the model) for each
# value of the parent choice point
# (If the model were to contain RecursionDepthSamplers then the conditional dependencies on recursion depth in these samplers
# would also estimated by this method.)
print("Estimating conditional model ... ")
estimateconditionalmodel(scm, selectedtraces)
println("done")

# pretty print the current choice model
println("Estimated conditional choice model: ")
println(scm)
println()

println("Sampling using estimated conditional choice model:")
# now only ax, cy, and dx should be returned: this would not be possible without conditionality in the model
# (bx and by are omitted as a result of estimation of the categorical distribution for the S rule choice point rather
# than the conditionality itself, and this would be possible with a call estimateparams: the call to estimateconditionalmodel
# additionaly estimates the dependencies and resulting conditional distributions)
for s in 1:1000
	result, state = generate(gn, choicemodel=scm)
	print("$(result) ")
end
println()


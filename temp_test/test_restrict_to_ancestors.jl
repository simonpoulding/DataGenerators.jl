#
# here, test specifically when the model is set to restrict conditionality to ancestors
#
# TODO:
#	- amendtrace
#	- depths other than 1
#	- nested conditional samplers
#	- model building

println("START test_restrict_to_ancestors")

using Base.Test
using GodelTest

# generator for arithmetic expressions
@generator AncestorGen begin
  start = A * B
  A = "a" * X
  B = "b" * U
  X = "x" * U
  X = "y" * U
  U = "u"
  U = "v"
end

# generator
gn = AncestorGen()

# get info required for testing
cpinfo = choicepointinfo(gn)
cpidX = nothing
cpidU = nothing
for cp in cpinfo
	(cpid, info) = cp
	if info[:rulename] == :X
		cpidX = cpid
	elseif info[:rulename] == :U
		cpidU = cpid
	end
end
@assert cpidX != nothing && cpidU != nothing # assert since this is not a test of the conditional sampler per se

# *** restrict to ancestors ***
scm = SamplerChoiceModel(gn)


@assert numparams(scm) == 4 # 2 categorical samplers, each with two choices
@assert sort(getparams(scm)) == [0.5, 0.5, 0.5, 0.5,] # need to do it this way because of orders withing Dicts aren't predictable
@assert haskey(scm.samplers, cpidX) && haskey(scm.samplers, cpidU)

#
# constructor
#
println("Testing constructor:")

# now make U choice point conditional on X choice point and restrict to ancestors
scm.samplers[cpidU] = GodelTest.ConditionalSampler(scm.samplers[cpidU], cpidX, 1, nothing, true, [1,2], Vector[[1.0, 0.0], [0.0, 1.0]])


# TODO: may be better to test the following methods on sampler itself rather than at CM level?


#
# sample
#
println("Testing sample:")

# println("before sampling: $(getparams(scm))")

# strings can only begin axu and ayv because of conditionality, but can end both bu and bv regardless of prefix
# if restrict to ancestors did not work when sampling, then only possible values would be axubu and ayvbv
#
counts = Dict("axubu"=>0, "axubv"=>0, "ayvbu"=>0, "ayvbv"=>0,)
samplesize = 1000
selectedtraces = Vector()
print("Sampling from model: ")
for s in 1:samplesize
	result, state = generate(gn, choicemodel=scm)
	print(".")
	@test haskey(counts, result)  # checks that only the four valid outputs are returned
	counts[result] += 1
	if result in ("axubv", "ayvbu")
		push!(selectedtraces, state.cmtrace)
	end
end
println()

# all four possible combinations of prefix / suffix should occur at least once (and actually all about 25%)
@test all(c->c>(samplesize*0.15),values(counts))

#
# estimateparams

println("Testing estimateparams:")

# The selectedtraces array was built from sampling above when u then v, or v then u was returned.
# If we now attempt to re-estimate the model from these samples, we should still have the same conditionality for U on
# X since the second value of U has no X ancestor.  If this were not restricting in this way when estimating parameters,
# then the two "histories" per sample would move conditionality to [0.5, 0.5] for both values of X.
# Since parameters for X choice point should also be the effectively same as before re-estimation, the 
# sampling should be broadly the same.
#
# TODO: could do with more positive testing of the restriction as well as this negative case. In particular, we can't
# distinguish this case from when estimateparams does nothing.
#
# ... for the moment, deal with this here by setting parameters of this sampler to something different that will detected 
# by generating unexpected outputs should the parameters not be estimated from the sample
setparams(scm.samplers[cpidU],[0.51,0.49,0.48,0.52,0.47,0.53])

estimateparams(scm, selectedtraces)

# strings can only begin axu and ayv, but can end both bu and bv regardless of prefix
counts = Dict("axubu"=>0, "axubv"=>0, "ayvbu"=>0, "ayvbv"=>0,)
samplesize = 1000
print("Sampling from re-estimated model: ")
for s in 1:samplesize
	result, state = generate(gn, choicemodel=scm)
	print(".")
	@test haskey(counts, result)  # checks that only the four valid outputs are returned
	counts[result] += 1
end
println()

# all four possible combinations of prefix / suffix should occur at least once (and actually all about 25%)
@test all(c->c>(samplesize*0.15),values(counts))

#
# TODO amendtrace 
#
println("TODO Testing amendtrace:")

println("END test_restrict_to_ancestors")

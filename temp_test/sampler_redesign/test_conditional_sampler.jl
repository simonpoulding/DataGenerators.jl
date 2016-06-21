# TODO:
#	- amendtrace
#	- depths other than 1
#	- nested conditional samplers

println("START test_conditional_sampler")

using Base.Test
using DataGenerators

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

# get info required for testing
cpinfo = choicepointinfo(gn)
cpidS = nothing
cpidX = nothing
for cp in cpinfo
	(cpid, info) = cp
	if info[:rulename] == :S
		cpidS = cpid
	elseif info[:rulename] == :X
		cpidX = cpid
	end
end
@assert cpidS != nothing && cpidX != nothing # assert since this is not a test of the conditional sampler per se



scm = SamplerChoiceModel(gn)

@assert numparams(scm) == 8 # 3 categorical samplers, one with 4 choices, two with 2
@assert sort(getparams(scm)) == [0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.5, 0.5] # need to do it this way because of orders withing Dicts aren't predictable
@assert haskey(scm.samplers, cpidX) && haskey(scm.samplers, cpidS)

#
# constructor
#
println("Testing constructor:")

# now make X choice point conditional on S choice point
scm.samplers[cpidX] = DataGenerators.ConditionalSampler(scm.samplers[cpidX], cpidS, 1, nothing, false, [1,3,nothing], Vector[[0.89, 0.11], [0.1, 0.9], [0.0, 1.0]])


# TODO: may be better to test the following methods on sampler itself rather than at CM level?


#
# numparams
#
println("Testing numparams:")

@test numparams(scm) == 14 # 2 choices for start, 4 choices for S, but now 8 for C: 2 for default, and 3 for each of the 2 values of S specified


#
# paramranges
#
println("Testing paramranges:")

@test paramranges(scm) == fill((0.0,1.0), 14) # 14 parameters, all the unit interval


#
# setparams
#
println("Testing setparams:")

oldparams = getparams(scm)
@test sort(oldparams) == [0.0,0.1,0.11,0.25,0.25,0.25,0.25,0.5,0.5,0.5,0.5,0.89,0.9,1.0] # need to do it this way because of orders withing Dicts aren't predictable
newparams = copy(oldparams)
# indexin returns highest match in the following; useful so we can amend consistently where multiple parameters are the same
# we do it this way because we don't know the order of choice points and within dictionaries of each sampler
# but can use the order of the existing values in oldparams to guide use
newparams[indexin([0.89],newparams)] = 0.7
newparams[indexin([0.11],newparams)] = 0.3
newparams[indexin([0.1],newparams)] = 0.2
newparams[indexin([0.9],newparams)] = 0.8
newparams[indexin([0.0],newparams)] = 0.99
newparams[indexin([1.0],newparams)] = 0.01
newparams[indexin([0.5],newparams)] = 0.6 
newparams[indexin([0.5],newparams)] = 0.4
newparams[indexin([0.5],newparams)] = 0.77 
newparams[indexin([0.5],newparams)] = 0.23
newparams[indexin([0.25],newparams)] = 0.28
newparams[indexin([0.25],newparams)] = 0.21
newparams[indexin([0.25],newparams)] = 0.12
newparams[indexin([0.25],newparams)] = 0.39
# println("newparams: $(newparams)")
setparams(scm, newparams)
@test getparams(scm) == newparams # can do this because ordering between set and get params should be consistent


#
# sample
#
println("Testing sample:")

setparams(scm, oldparams)
@assert getparams(scm) == oldparams
# println("before sampling: $(getparams(scm))")

counts = Dict("ax"=>0, "ay"=>0, "bx"=>0, "by"=>0, "cx"=>0, "cy"=>0, "dx"=>0, "dy"=>0, "x"=>0, "y"=>0)
samplesize = 10000
selectedtraces = Vector()
print("Sampling from 'oldparams' model: ")
for s in 1:samplesize
	result, state = generate(gn, choicemodel=scm)
	print(".")
	if result in ("ax", "cy", "dx", "y")
		push!(selectedtraces, state.cmtrace)
	end
	# println("result: $(result)")
	@test haskey(counts, result)  # checks that only the ten valid outputs are returned
	counts[result] += 1
end
println()

# approx 50% should be two letters followed by x or y, each first letter is equally likely, therefore a*, b*, c*, d* each about 12.5%
afreq = 0.5 * 0.25 * samplesize
bfreq = 0.5 * 0.25 * samplesize
cfreq = 0.5 * 0.25 * samplesize
dfreq = 0.5 * 0.25 * samplesize
deviation = 0.02 * samplesize
# since: x is preferred to y once a has been chosen by 9 to 1
@test abs(counts["ax"] - afreq * 0.9) < deviation
@test abs(counts["ay"] - afreq * 0.1) < deviation
# since: y is preferred to x once c has been chosen by 9 to 1
@test abs(counts["cx"] - cfreq * 0.1) < deviation
@test abs(counts["cy"] - cfreq * 0.9) < deviation
# but for B and D "default" sampler should be used, resulting in roughly equal numbers
@test abs(counts["bx"] - bfreq * 0.5) < deviation
@test abs(counts["by"] - bfreq * 0.5) < deviation
@test abs(counts["dx"] - dfreq * 0.5) < deviation
@test abs(counts["dy"] - dfreq * 0.5) < deviation
# when derivation goes from start to X directly (which happens 50 of the time), the output should only be y's
@test counts["x"] == 0
@test abs(counts["y"] - 0.5 * samplesize) < deviation

#
# estimateparams
#
println("Testing estimateparams:")

# The selectedtraces array was built from sampling above when ax, cy, dx, or y were returned, this therefore should change 
# conditional probabilities so that *only* these values are returned (a non-conditional model could not achieve this since X 
# must be conditional on the letter that comes before it).
# Note that re-estimation will also change other choice points so that B is never chosen,
# and other frequencies adjusted to proportions in the selectedtraces, but we don't check that here.

estimateparams(scm, selectedtraces)

newcounts = Dict("ax"=>0, "cy"=>0, "dx"=>0, "y"=>0)
# only ax, cy, dx, and y should be returned from re-estimated model
newsamplesize = 10000
print("Sampling from re-estimated model: ")
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

#
# TODO amendtrace 
#
println("TODO Testing amendtrace:")

println("END test_conditional_sampler")

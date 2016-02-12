using Base.Test
using GodelTest

println("START test_poisson_sampler")

# some setup for calling sampler method

type DummyDerivationState <: GodelTest.DerivationState
end

# type ChoiceContext
# 	derivationstate::DerivationState
# 	cptype::Symbol
# 	cpid::UInt64
# 	datatype::DataType
# 	lowerbound::Real
# 	upperbound::Real
# end
cc = GodelTest.ChoiceContext(DummyDerivationState(), GodelTest.SEQUENCE_CP, convert(UInt64,0), Int, typemin(Int), typemax(Int)) 


println("Testing default constructor")

s = GodelTest.PoissonSampler()
@test numparams(s) == 1
@test paramranges(s) == [(0.0, maxintfloat(Float64))] # really just need to check for "large" upper limit
@test getparams(s) == [1.0] # default of 1.0

gntotal = 0.0
samplesize = 1000
for i in 1:samplesize
	gn, trace = GodelTest.sample(s,(typemin(Int),typemax(Int)), cc)
	@test typeof(gn) <: Integer
	@test 0 <= gn
	@test trace[:rnd] == gn
	gntotal += gn
end
@test 0.9 <= (gntotal/samplesize) <= 1.1 # mean should be 1.0


println("Testing constructor")

s = GodelTest.PoissonSampler([4.1])
@test numparams(s) == 1
@test paramranges(s) == [(0.0, maxintfloat(Float64))] # really just need to check for "large" upper limit
@test getparams(s) == [4.1]

gntotal = 0.0
samplesize = 1000
for i in 1:samplesize
	gn, trace = GodelTest.sample(s,(typemin(Int),typemax(Int)), cc)
	@test typeof(gn) <: Integer
	@test 0 <= gn
	@test trace[:rnd] == gn
	gntotal += gn
end
@test 3.7 <= (gntotal/samplesize) <= 4.5 # mean should be 4.1


println("Testing setparams")

s = GodelTest.PoissonSampler()
setparams(s, [17.5])
@test numparams(s) == 1
@test paramranges(s) == [(0.0, maxintfloat(Float64))] # really just need to check for "large" upper limit
@test getparams(s) == [17.5]

gntotal = 0.0
samplesize = 1000
for i in 1:samplesize
	gn, trace = GodelTest.sample(s,(typemin(Int),typemax(Int)), cc)
	@test typeof(gn) <: Integer
	@test 0 <= gn
	@test trace[:rnd] == gn
	gntotal += gn
end
@test 16.5 <= (gntotal/samplesize) <= 18.5 # mean should be 17.5

println("Testing estimateparams")

s = GodelTest.PoissonSampler([8.5])

traces = Any[]
gntotal = 0.0
samplecount = 0
samplesize = 1000
for i in 1:samplesize
	gn, trace = GodelTest.sample(s,(typemin(Int),typemax(Int)), cc)
	if gn < 8.5
		gntotal += gn
		samplecount += 1
		push!(traces, trace)
	end
end

estimateparams(s, traces)
meanoftraces = gntotal/samplecount
ps = getparams(s)
@test abs(meanoftraces - ps[1]) < 0.5 # actually will be identical as Distributions uses sample mean as estimator of lambda


println("Testing sampling and estimating at min parameter value:")

s = GodelTest.PoissonSampler([0.0])

traces = Any[]
gntotal = 0.0
samplesize = 1000
for i in 1:samplesize
	gn, trace = GodelTest.sample(s,(typemin(Int),typemax(Int)), cc)
	gntotal += gn
	push!(traces, trace)
end

estimateparams(s, traces)
meanoftraces = gntotal/samplecount
ps = getparams(s)
@test abs(meanoftraces - ps[1]) < 0.5

println("Testing sampling and estimating at max parameter value:")

s = GodelTest.PoissonSampler([maxintfloat(Float64)])

traces = Any[]
gntotal = 0.0
samplesize = 1000
for i in 1:samplesize
	gn, trace = GodelTest.sample(s,(typemin(Int),typemax(Int)), cc)
	gntotal += gn
	push!(traces, trace)
end

estimateparams(s, traces)
meanoftraces = gntotal/samplesize
ps = getparams(s)
@test (abs(meanoftraces - ps[1])/meanoftraces) < 0.01

println("END test_poisson_sampler")

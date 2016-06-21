# find midpoint of a range without causing an overflow to Inf
function robustmidpoint(a::Float64,b::Float64)
	l = min(a,b)
	u = max(a,b)
	if sign(l) == sign(u)
		m = l + (u-l)/2
	else
		m = (u+l)/2
	end
	m
end


#
# Functions to check that observed distribution is consistent with passed parameters
# this is not ideal, because:
#
# (1) Much of the same special handling of parameter edge cases to avoid limitations in Distributions.jl
#     must by necessity be repeated here (although using slightly different code)
# (2) We use ranksum test (which seems to be suitably effective and sensitive), but perhaps should
#     use KS or similar - ranksum might fail, for example, to detect a reduced interval for a uniform dist
# (3) The samplesize of 100 is arbitrary - appears in practice to give a suitable power, but have not
#     analysed this
#

# create dummy choice context 
# for all apart from the ConditionalSampler, the choice context is not required
type DummyDerivationState <: GodelTest.DerivationState
end

dummyChoiceContext() = GodelTest.ChoiceContext(DummyDerivationState(), GodelTest.RULE_CP, 0, Int, 0, 0)


using HypothesisTests

function isconsistentbernoulli(s::GodelTest.Sampler, params::Vector{Float64}; support=(0,1), samplesize=100)
	aparams = copy(params)
	cc = dummyChoiceContext()
	xs = map(i->first(GodelTest.sample(s, support, cc)), 1:samplesize)
	ys = rand(Distributions.Bernoulli(aparams[1]), samplesize)
	pvalue(MannWhitneyUTest(xs,ys)) > 0.0001
end

function isconsistentcategorical(s::GodelTest.Sampler, params::Vector{Float64}; support=(0,1), samplesize=100)
	aparams = sum(params) == 0 ? fill(0.0, length(params)) : params / sum(params)
	cc = dummyChoiceContext()
	xs = map(i->first(GodelTest.sample(s, support, cc)), 1:samplesize)
	ys = rand(Distributions.Categorical(aparams), samplesize)
	pvalue(MannWhitneyUTest(xs,ys)) > 0.0001
end

function isconsistentdiscreteuniform(s::GodelTest.Sampler, params::Vector{Float64}; support=(0,1), samplesize=100)
	aparams = [minimum(params), maximum(params)]
	aparams = map(p->int128(round(p)), aparams)
	aparams = map(p->max(p, typemin(Int)+1), aparams) # to avoid error in DiscreteUniform
	aparams = map(p->min(p, typemax(Int)-1), aparams) # to avoid error in DiscreteUniform 
	cc = dummyChoiceContext()
	xs = map(i->first(GodelTest.sample(s, support, cc)), 1:samplesize)
	ys = rand(Distributions.DiscreteUniform(aparams[1], aparams[2]), samplesize)
	pvalue(MannWhitneyUTest(xs,ys)) > 0.0001
end

function isconsistentgeometric(s::GodelTest.Sampler, params::Vector{Float64}; support=(0,1), samplesize=100)
	aparams = [max(min(params[1],0.99999),0.00001)] # to avoid error in Geometric
	cc = dummyChoiceContext()
	xs = map(i->first(GodelTest.sample(s, support, cc)), 1:samplesize)
	ys = rand(Distributions.Geometric(aparams[1]), samplesize)
	pvalue(MannWhitneyUTest(xs,ys)) > 0.0001
end

function isconsistentnormal(s::GodelTest.Sampler, params::Vector{Float64}; support=(0,1), samplesize=100)
	aparams = [params[1], max(params[2], nextfloat(0.0))] # sigma can't be zero
	cc = dummyChoiceContext()
	xs = map(i->first(GodelTest.sample(s, support, cc)), 1:samplesize)
	ys = rand(Distributions.Normal(aparams[1], aparams[2]), samplesize)
	pvalue(MannWhitneyUTest(xs,ys)) > 0.0001
end

function isconsistenttruncatednormal(s::GodelTest.Sampler, params::Vector{Float64}; support=(0,1), samplesize=100)
	aparams = [params[1], max(params[2], nextfloat(0.0)), minimum(params[3:4]), maximum(params[3:4])] # sigma can't be zero
	cc = dummyChoiceContext()
	xs = map(i->first(GodelTest.sample(s, support, cc)), 1:samplesize)
	if aparams[1]==aparams[2]
		ys = map(i->aparams[1], 1:samplesize) # to avoid error in TruncatedNormal when bounds are equal
	else
		ys = rand(Distributions.TruncatedNormal(aparams[1], aparams[2]), samplesize)
	end
	pvalue(MannWhitneyUTest(xs,ys)) > 0.0001
end

function isconsistentuniform(s::GodelTest.Sampler, params::Vector{Float64}; support=(0,1), samplesize=100)
	aparams = [minimum(params), maximum(params)]
	m = robustmidpoint(aparams[1], aparams[2])
	if m-aparams[1] > realmax(Float64)/2
		# need to adjust to avoid a range more than realmax(Float64)
		aparams = [m-realmax(Float64)/2, m+realmax(Float64)/2]
	end
	cc = dummyChoiceContext()
	xs = map(i->first(GodelTest.sample(s, support, cc)), 1:samplesize)
	if aparams[1]==aparams[2]
		ys = map(i->aparams[1], 1:samplesize) # to avoid error in Uniform when bounds are equal
	else
		ys = rand(Distributions.Uniform(aparams[1], aparams[2]), samplesize)
	end
	pvalue(MannWhitneyUTest(xs,ys)) > 0.0001
end



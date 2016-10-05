# a distribution sampler samples from a named univariate parameter distribution; it ignores any support constraints
abstract DistributionSampler <: Sampler
abstract DiscreteDistributionSampler <: DistributionSampler
abstract ContinuousDistributionSampler <: DistributionSampler

paramranges(s::DistributionSampler) = copy(s.paramranges)

function sample(s::DistributionSampler, support, cc::ChoiceContext)
 x = rand(s.distribution)
 # we return both the sampled value, and a dict as trace information
 x, Dict{Symbol,Any}(:rnd=>x)
end

function extractsamplesfromtraces(s::DistributionSampler, traces)
	samples = map(trace->trace[:rnd], traces)
	convert(typeof(s) <: DiscreteDistributionSampler ? Vector{Int} : Vector{Float64}, samples)
end
	
function estimateparams(s::DistributionSampler, traces)
	samples = extractsamplesfromtraces(s, traces)
	minnumsamples = typeof(s.distribution) in [Normal,] ? 2 : 1
	if length(samples) >= minnumsamples
		s.distribution = fit(getdistributiontype(s), samples) 
	end
end

amendtrace(s::DistributionSampler, trace, x) = trace[:rnd] = x

include("sampler_utils.jl")
include("bernoulli_sampler.jl")
include("categorical_sampler.jl")
include("discrete_uniform_sampler.jl")
include("geometric_sampler.jl")
include("normal_sampler.jl")
include("uniform_sampler.jl")
include("poisson_sampler.jl")

# pretty print the sampler
function show(io::IO, s::DistributionSampler, indentdepth::Int=1)
	# since this sampler will be a 'leaf' in the sampler tree, can finish with a new line
	println(io, getsamplertypename(s) * " $(getparams(s))")
end

minimumsupport(s::DistributionSampler) = minimum(s.distribution)

# This is a workaround for Distributions.jl 0.11.0 - in this version
# Bernoulli and Categorical become parameterised types, but using such
# a parameterised type as the first argument of fit() raises an error
# As a workaround, we revert the type back to the primary via the typename,
# effectively removing any workaround
getdistributiontype(s::DistributionSampler) = typeof(s.distribution).name.primary
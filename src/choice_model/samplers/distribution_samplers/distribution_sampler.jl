# a distribution sampler samples from a named univariate parameter distribution; it ignores any support constraints
abstract DistributionSampler <: Sampler

abstract DiscreteDistributionSampler <: DistributionSampler
abstract ContinuousDistributionSampler <: DistributionSampler

paramranges(s::DistributionSampler) = copy(s.paramranges)

function sample(s::DistributionSampler, support)
 x = rand(s.distribution)
 # we return both the sampled value, and a dict as trace information
 x, {:dist=>x}
end

function estimateparams(s::DistributionSampler, traces)
	samples = map(trace->trace[:dist], traces)
	samples = convert(typeof(s) <: DiscreteDistributionSampler ? Vector{Int} : Vector{Float64}, samples)
	minsamples = typeof(s.distribution) in [Normal,] ? 2 : 1
	if length(samples) >= minsamples
		s.distribution = fit(typeof(s.distribution), samples)
	end
end

include("bernoulli_sampler.jl")
include("categorical_sampler.jl")
include("discrete_uniform_sampler.jl")
include("geometric_sampler.jl")
include("normal_sampler.jl")
include("uniform_sampler.jl")

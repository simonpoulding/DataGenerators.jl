# a distribution sampler samples from a named univariate parameter distribution; it ignores any support constraints
abstract DistributionSampler <: Sampler

abstract DiscreteDistributionSampler <: DistributionSampler
abstract ContinuousDistributionSampler <: DistributionSampler

paramranges(s::DistributionSampler) = copy(s.paramranges)

getparams(s::DistributionSampler) = copy(s.params)

sample(s::DistributionSampler, support::(Real,Real)) = rand(s.distribution)

include("bernoulli_sampler.jl")
include("categorical_sampler.jl")
include("discrete_uniform_sampler.jl")
include("geometric_sampler.jl")
include("uniform_sampler.jl")
include("gaussian_sampler.jl")

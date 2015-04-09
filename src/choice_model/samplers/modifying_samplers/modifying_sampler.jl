# a modifying sampler modifies one or more distribution samplers or other modifying samplers
abstract ModifyingSampler <: Sampler

paramranges(s::ModifyingSampler) = paramranges(s.subsampler)

getparams(s::ModifyingSampler) = getparams(s.subsampler)

setparams(s::ModifyingSampler, params::Vector{Float64}) = setparams(s.subsampler, params)

sample(s::ModifyingSampler, support::(Real,Real)) = sample(s.subsampler, support)

include("mixture_sampler.jl")
include("truncate_to_support_sampler.jl")
include("adjust_to_support_sampler.jl")
include("transforming_sampler.jl")
include("constrain_parameters_sampler.jl")
# include("translate_to_min_support_sampler.jl")



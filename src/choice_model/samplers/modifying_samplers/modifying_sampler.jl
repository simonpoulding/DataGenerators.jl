# a modifying sampler modifies one or more distribution samplers or other modifying samplers
abstract ModifyingSampler <: Sampler

paramranges(s::ModifyingSampler) = paramranges(s.subsampler)

getparams(s::ModifyingSampler) = getparams(s.subsampler)

setparams(s::ModifyingSampler, params) = setparams(s.subsampler, params)

function sample(s::ModifyingSampler, support)
	x, trace = sample(s.subsampler, support)
	x, {:sub=>trace}
end

estimateparams(s::ModifyingSampler, traces) = estimateparams(s.subsampler, map(trace->trace[:sub], traces))

include("mixture_sampler.jl")
include("truncate_to_support_sampler.jl")
include("adjust_parameters_to_support_sampler.jl")
include("align_min_support_sampler.jl")
include("transforming_sampler.jl")
include("constrain_parameters_sampler.jl")
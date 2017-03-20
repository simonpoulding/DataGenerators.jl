#
# Adjust Parameters to Support Sampler
#
# adjust the parameters of the sampler so that values are returned in support
# Only some samplers can be adjusted in this way; for others an error is raised on construction
#

type AdjustParametersToSupportSampler <: ModifyingSampler
	subsampler::Sampler
	function AdjustParametersToSupportSampler(subsampler::Sampler)
		typeof(subsampler) in (UniformSampler, DiscreteUniformSampler,) || error("$(typeof(subsampler)) samplers are not supported by AdjustParametersToSupportSampler")
		new(subsampler)
	end
end

function paramranges(s::AdjustParametersToSupportSampler)
	if typeof(s.subsampler) in (UniformSampler, DiscreteUniformSampler,)
		return Tuple{Float64,Float64}[]
	else
		@assert false
	end
end

function getparams(s::AdjustParametersToSupportSampler)
	if typeof(s.subsampler) in (UniformSampler, DiscreteUniformSampler,)
		return (Float64)[]
	else
		@assert false
	end
end

function setparams!(s::AdjustParametersToSupportSampler, params)
	nparams = length(paramranges(s))
	length(params) == nparams || error("expected $(nparams) parameters but got $(length(params))")
	if typeof(s.subsampler) in (UniformSampler, DiscreteUniformSampler,)
		nothing
	else
		@assert false
	end
end

function sample(s::AdjustParametersToSupportSampler, support, cc::ChoiceContext)
	if typeof(s.subsampler) in (UniformSampler, DiscreteUniformSampler,)
		setparams!(s.subsampler, [Float64(support[1]), Float64(support[2])])
	else
		@assert false
	end
	x, trace = sample(s.subsampler, support, cc)
	x, Dict{Symbol, Any}(:sub=>trace)
end


function estimateparams!(s::AdjustParametersToSupportSampler, traces)
	if typeof(s.subsampler) in (UniformSampler, DiscreteUniformSampler,)
		nothing
	else
		@assert false
	end
end



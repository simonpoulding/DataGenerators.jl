#
# Mixture Sampler
#
# a mixture of two or more samplers
#

type MixtureSampler <: ModifyingSampler
	selectionsampler::CategoricalSampler
	subsamplers
	function MixtureSampler(subsamplers...)
		length(subsamplers) >= 2 || error("At least two subsamplers are required")
		for sampler in subsamplers
			typeof(sampler) <: Sampler || error("Not all parameters are samplers")
		end
		new(CategoricalSampler(length(subsamplers)), subsamplers)
	end
end

numparams(s::MixtureSampler) = numparams(s.selectionsampler) + sum(numparams, s.subsamplers)

function paramranges(s::MixtureSampler)
	pr = paramranges(s.selectionsampler)
	for subsampler in s.subsamplers
		pr = [pr, paramranges(subsampler)]
	end
	pr
end

function setparams(s::MixtureSampler, params::Vector{Float64})
	nparams = numparams(s)
	length(params) == nparams || error("expected $(nparams) parameters but got $(length(params))")
	paramstart = 1
	paramcount = numparams(s.selectionsampler)
	setparams(s.selectionsampler, params[paramstart:(paramstart+paramcount-1)])
	for subsampler in s.subsamplers
		paramstart += paramcount
		paramcount = numparams(subsampler)
		setparams(subsampler, params[paramstart:(paramstart+paramcount-1)])
	end
end

function getparams(s::MixtureSampler)
	ps = getparams(s.selectionsampler)
	for subsampler in s.subsamplers
		ps = [ps, getparams(subsampler)]
	end
	ps
end

function sample(s::MixtureSampler, support::(Real,Real))
	selection = sample(s.selectionsampler, (1,length(s.subsamplers)))
	sample(s.subsamplers[selection], support)
end


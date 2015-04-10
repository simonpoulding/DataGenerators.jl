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

function setparams(s::MixtureSampler, params)
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

function sample(s::MixtureSampler, support)
	selectionindex, selectiontrace = sample(s.selectionsampler, (1,length(s.subsamplers)))
	x, trace = sample(s.subsamplers[selectionindex], support)
	x, {:idx=>selectionindex, :sel=>selectiontrace, :sub=>trace}
end

function estimateparams(s::MixtureSampler, traces)
	estimateparams(s.selectionsampler, map(trace->trace[:sel], traces))
	subsamplertraces = map(i->{}, 1:length(s.subsamplers))
	for trace in traces
		selectionindex = trace[:idx]
		push!(subsamplertraces[selectionindex], trace[:sub])
	end
	for i in 1:length(s.subsamplers)
		estimateparams(s.subsamplers[i], subsamplertraces[i])		
	end
end

amendtrace(s::MixtureSampler, trace, x) = amendtrace(s.subsamplers[trace[:idx]], trace[:sub], x)

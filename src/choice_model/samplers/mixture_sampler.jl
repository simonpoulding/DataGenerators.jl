#
# Mixture Sampler
#

type MixtureSampler <: Sampler
	subsamplers::Vector{Sampler}
	internaldist::CategoricalDist
	function MixtureSampler(subsamplers::Vector)
		length(subsamplers) >= 2 || error("At least two subsamplers are required")
		new(subsamplers, CategoricalDist(length(subsamplers)))
	end
end

numparams(ds::MixtureSampler) = numparams(ds.internaldist) + sum(numparams, ds.subsamplers)

function paramranges(ds::MixtureSampler)
	pr =  paramranges(ds.internaldist)
	for subsampler in ds.subsamplers
		pr = [pr, paramranges(subsampler)]
	end
	pr
end

function setparams(ds::MixtureSampler, params::Vector{Float64})
	nparams = numparams(ds)
	length(params) == nparams || error("expected $(nparams) parameters but got $(length(params))")
	
	paramstart = 1
	paramcount = numparams(ds.internaldist)
	setparams(ds.internaldist, params[paramstart:(paramstart+paramcount-1)])
	
	for subsampler in ds.subsamplers
		paramstart += paramcount
		paramcount = numparams(subsampler)
		setparams(subsampler, params[paramstart:(paramstart+paramcount-1)])
	end
end

function getparams(ds::MixtureSampler)
	ps =  getparams(ds.internaldist)
	for subsampler in ds.subsamplers
		ps = [ps, getparams(subsampler)]
	end
	ps
end

godelnumber(ds::MixtureSampler,  cc::ChoiceContext) = godelnumber(ds.subsamplers[sample(ds.internaldist)], cc)


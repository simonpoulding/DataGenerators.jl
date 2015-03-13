#
# Constrained Parameters Sampler
# used to constain the subsamplers param ranges
#

type ConstrainedParametersSampler <: Sampler
	subsampler::Sampler
	constrainedparamranges::Vector{(Float64,Float64)}
	function ConstrainedParametersSampler(subsampler::Sampler, constrainedparamranges::Vector{(Float64,Float64)})
		samplerparamranges = paramranges(subsampler)
		samplerparams = getparams(subsampler)
		adjustedsamplerparams = Float64[]
		length(samplerparamranges) == length(constrainedparamranges) || error("number of constrained parameter ranges must equal number of parameters for subsampler")
		for i in 1:length(constrainedparamranges)
			constrainedparamrange = constrainedparamranges[i]
			constrainedparamrange[1] <= constrainedparamrange[2] ||	error("for $(i)th constrained parameters, the lower bound must be less than or equal to the upper bound")
			samplerparamrange = samplerparamranges[i]
			if (constrainedparamrange[1] < samplerparamrange[1]) || (constrainedparamrange[2] > samplerparamrange[2])
				error("for $(i)th parameters, the constrained parameter range extends outside the sampler's parameter range")
			end
			# adjust sampler params to be consistent with the constraints
			push!(adjustedsamplerparams, min(constrainedparamrange[2], max(constrainedparamrange[1], samplerparams[i])))
		end
		setparams(subsampler, adjustedsamplerparams)
		new(subsampler, constrainedparamranges)
	end
end

numparams(ds::ConstrainedParametersSampler) = length(ds.constrainedparamranges)

paramranges(ds::ConstrainedParametersSampler) = ds.constrainedparamranges

function setparams(ds::ConstrainedParametersSampler, params::Vector{Float64})
	for i in 1:length(ds.constrainedparamranges)
		param = params[i]
		constrainedparamrange = ds.constrainedparamranges[i]
		if !(constrainedparamrange[1] <= param <= constrainedparamrange[2])
			error("$(i)th parameter should be in range $(constrainedparamrange[1]) to $(constrainedparamrange[2]), but got $(param)")
		end
	end
	setparams(ds.subsampler, params)
end

getparams(ds::ConstrainedParametersSampler) = getparams(ds.subsampler)

godelnumber(ds::ConstrainedParametersSampler,  cc::ChoiceContext) = godelnumber(ds.subsampler, cc)

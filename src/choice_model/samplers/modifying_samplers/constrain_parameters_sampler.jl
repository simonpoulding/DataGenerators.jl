#
# Constrain Parameters Sampler
#
# constrains the parameter ranges of the subsampler
#

type ConstrainParametersSampler <: ModifyingSampler
	subsampler::Sampler
	constrainedparamranges::Vector{(Float64,Float64)}
	function ConstrainParametersSampler(subsampler::Sampler, constrainedparamranges)
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

function setparams(s::ConstrainParametersSampler, params)
	checkparamranges(s, params)
	setparams(s.subsampler, params)
end

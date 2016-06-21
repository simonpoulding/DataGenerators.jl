#
# Constrain Parameters Sampler
#
# constrains the parameter ranges of the subsampler
#
# note: does not enforce actual parameter, nor estimated parameters, to the constrained range
#

type ConstrainParametersSampler <: ModifyingSampler
	subsampler::Sampler
	paramranges::Vector{Tuple{Float64,Float64}}
	function ConstrainParametersSampler(subsampler::Sampler, constrainprs::Vector{Tuple{Float64,Float64}})
		subsamplerprs = paramranges(subsampler)
		length(subsamplerprs) == length(constrainprs) || error("number of constrained parameter ranges does not match number of subsampler parameters")
		prs = Tuple{Float64,Float64}[]
		for i in 1:length(constrainprs)
			cpr = constrainprs[i]
			cpr[1] <= cpr[2] || error("$(i)th constrained parameter range has lower bound greater than upper bound")
			sspr = subsamplerprs[i]
			pr = (max(sspr[1],cpr[1]), min(sspr[2],cpr[2]))
			pr[1] <= pr[2] || error("$(i)th constrained parameter range lies outside subsampler range")
			push!(prs, pr)
		end
		new(subsampler, prs)
	end
end

paramranges(s::ConstrainParametersSampler) = s.paramranges

function setparams(s::ConstrainParametersSampler, params)
	checkparamranges(s, params)
	setparams(s.subsampler, params)
end

minimumsupport(s::ConstrainParametersSampler) = minimumsupport(s.subsampler)
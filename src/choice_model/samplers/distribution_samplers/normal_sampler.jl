#
# Normal Sampler
#
# parameters:
# 	(1) mu 
#	(2) sigma
#

type NormalSampler <: ContinuousDistributionSampler
	paramranges::Vector{(Float64,Float64)}
	distribution::Normal
	function NormalSampler(params=Float64[])
		# Distributions.Normal returns samples of NaN if mean is -Inf and sigma is Inf
		# therefore limit sigma to realmax(Float64)
		s = new([(-Inf,Inf),(0.0,realmax(Float64))])
		setparams(s, isempty(params) ? [0.0, 1.0] : params)
		s
	end
end

function setparams(s::NormalSampler, params)
	checkparamranges(s, params)
	μ = params[1]
	σ = max(eps(0.0),params[2]) # sigma cannot be exactly 0.0
	s.distribution = Normal(μ, σ)
end

getparams(s::NormalSampler) = [s.distribution.μ, s.distribution.σ]
# TODO should sample actually sample Inf?


#
# Gaussian Sampler
#
# parameters:
# 	(1) mu 
#	(2) sigma
#

type GaussianSampler <: ContinuousDistributionSampler
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Normal
	function GaussianSampler(params::Vector{Float64}=Float64[])
		# Distributions.Gaussian returns samples of NaN if mean is -Inf and sigma is Inf
		# therefore limit sigma to realmax(Float64)
		s = new([(-Inf,Inf),(0.0,realmax(Float64))])
		setparams(s, isempty(params) ? [0.0, 1.0] : params)
		s
	end
end

function setparams(s::GaussianSampler, params::Vector{Float64})
	checkparamranges(s, params)
	params[2] = max(eps(0.0),params[2]) # sigma cannot be exactly 0.0
	s.params = params
	s.distribution = Normal(s.params[1], s.params[2])
end

# TODO should sample actually sample Inf?


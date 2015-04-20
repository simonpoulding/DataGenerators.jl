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
		# We restrict the range of the real-values parameters to less than the entire float range
		# in order to avoid overflow errors in Distributions.Normal
		# We use sqrt of the bound for sigma on the basis that it is the calculation of the variance
		# that can cause an overflow
		s = new( [(-realmax(Float64), realmax(Float64)), (0, realmax(Float64))] )
		setparams(s, isempty(params) ? [0.0, 1.0] : params)
		s
	end
end

function setparams(s::NormalSampler, params)
	checkparamranges(s, params)
	μ, σ = params[1], max(nextfloat(0.0), params[2]) # sigma cannot be zero
	s.distribution = Normal(μ, σ)
end

getparams(s::NormalSampler) = [s.distribution.μ, s.distribution.σ]
# TODO should sample actually sample Inf?


#
# Bernoulli Sampler
#
# parameters:
# 	(1) 0 <= p <= 1
#

type BernoulliSampler <: DiscreteDistributionSampler
	paramranges::Vector{Tuple{Float64,Float64}}
	distribution::Bernoulli
	function BernoulliSampler(params=Float64[])
		s = new(Tuple{Float64,Float64}[(0.0,1.0)])
		setparams!(s, isempty(params) ? Float64[0.5] : params)
		s
	end
end

function setparams!(s::BernoulliSampler, params)
	checkparamranges(s, params)
	p = params[1]
	s.distribution = Bernoulli(p)
end

getparams(s::BernoulliSampler) = [s.distribution.p]

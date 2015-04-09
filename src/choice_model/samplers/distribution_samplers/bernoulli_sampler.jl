#
# Bernoulli Sampler
#
# parameters:
# 	(1) 0 <= p <= 1
#

type BernoulliSampler <: DiscreteDistributionSampler
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Bernoulli
	function BernoulliSampler(params::Vector{Float64}=Float64[])
		s = new([(0.0,1.0)])
		setparams(s, isempty(params) ? Float64[0.5] : params)
		s
	end
end

function setparams(s::BernoulliSampler, params::Vector{Float64})
	checkparamranges(s, params)
	s.params = copy(params)
	s.distribution = Bernoulli(s.params[1])
end



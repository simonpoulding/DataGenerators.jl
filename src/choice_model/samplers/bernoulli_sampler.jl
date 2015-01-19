#
# Bernoulli Sampler
#

type BernoulliSampler <: DistSampler
	dist::BernoulliDist
	function BernoulliSampler()
		new(BernoulliDist())
	end
end


#
# Geometric Sampler
#

type GeometricSampler <: Sampler
	dist::GeometricDist
	function GeometricSampler()
		new(GeometricDist)
	end
end

function godelnumber(s::GeometricSampler, cc::ChoiceContext)
	if (cc.upperbound - cc.lowerbound) < (s.supportlowerquartile - s.lowerbound)
		# if range specified by the choice context is smaller than the lower quartile of the distribution
		# then multiple resamplings are likely in the choice model to enforce the upperbound
		# in this situation fall back to a uniform distribution
		# info("geometric falling back to discrete uniform")
		sample(DiscreteUniformDist(cc.lowerbound, cc.upperbound))
	else
		sample(ds.dist) + cc.lowerbound - ds.dist.supportlowerbound
	end
end
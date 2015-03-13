#
# Uniform Sampler
# - uses a Uniform distribution that has a support of [lowerbound, upperbound] as specified by the choicepoint
#

type UniformSampler <: DistSampler
	dist::UniformDist
	function UniformSampler()
		new(UniformDist(0.0,1.0))
	end
end

function godelnumber(ds::UniformSampler,  cc::ChoiceContext)
	gn = cc.lowerbound
	if cc.lowerbound < cc.upperbound
		if (cc.lowerbound != ds.dist.lowerbound) || (cc.upperbound != ds.dist.upperbound)
			ds.dist = UniformDist(cc.lowerbound, cc.upperbound)
		end
		gn = sample(ds.dist)
	end
	gn
end
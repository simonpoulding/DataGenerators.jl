#
# Discrete Uniform Sampler
# - uses a Discrete Uniform distribution that has a support of [lowerbound, upperbound] as specified by the choicepoint
#

type DiscreteUniformSampler <: DistSampler
	dist::DiscreteUniformDist
	function DiscreteUniformSampler()
		new(DiscreteUniformDist(0,1))
	end
end

function godelnumber(ds::DiscreteUniformSampler,  cc::ChoiceContext)
	gn = cc.lowerbound
	if cc.lowerbound < cc.upperbound
		if (cc.lowerbound != ds.dist.lowerbound) || (cc.upperbound != ds.dist.upperbound)
			ds.dist = DiscreteUniformDist(cc.lowerbound, cc.upperbound)
		end
		gn = sample(ds.dist)
	end
	gn
end
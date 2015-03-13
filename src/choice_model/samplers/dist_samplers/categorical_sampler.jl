#
# Categorical Sampler
# - uses a Categorical distribution that has a support over the range 1:numcategories
#

type CategoricalSampler <: DistSampler
	dist::CategoricalDist
	function CategoricalSampler(numcategories::Int)
		new(CategoricalDist(numcategories))
	end
end

#
# Gaussian Sampler
#

type GaussianSampler <: DistSampler
	dist::GaussianDist
	function GaussianSampler()
		new(GaussianDist())
	end
end

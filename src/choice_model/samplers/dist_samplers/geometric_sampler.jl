#
# Geometric Sampler
#

type GeometricSampler <: DistSampler
	dist::GeometricDist
	function GeometricSampler()
		new(GeometricDist())
	end
end

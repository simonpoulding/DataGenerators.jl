#
# Truncate to Support Sampler
#
# ensures that the sampled value is within defined support
# only DistributionSamplers are supported
#
# We use the Truncated functionality of the Distributions package, but this currently does not
# handle all underlying distributions.
# We leave it to the Distributions to raise an error when it is not compatible: the advantage is that
# additional distributions will be automatically handled should the Distributions package handle them
# in future versions.
#

type TruncateToSupportSampler <: ModifyingSampler
	subsampler::DistributionSampler
	function TruncateToSupportSampler(subsampler::DistributionSampler)
		new(subsampler)
	end
end

function sample(s::TruncateToSupportSampler, support, cc::ChoiceContext)
	# TODO: check whether it is better to store truncated distribution, and only
	# recreate when support changes.  If so, will need to trap setparams call so
	# as to clear any stored truncated distribution
	if support[1] == support[2]
		# can give an error when support[1] == support[2]
		x = support[1]
	else
		truncateddistribution = Truncated(s.subsampler.distribution, support[1], support[2])
		x = rand(truncateddistribution)
	end
	x, Dict{Symbol, Any}(:sub=>Dict{Symbol, Any}(:rnd=>x))
end


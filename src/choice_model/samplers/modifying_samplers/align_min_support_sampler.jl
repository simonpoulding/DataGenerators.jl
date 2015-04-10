#
# Align Min Support Sampler
#
# adds a fixed value to sampled value so that minimum of requested support is aligned to minimum of support of 
# the subsampler (which is assumed to be a DistributionSampler)
# note: this is intended to be used with distributions with finite minimum support, but no error is explicitly raised
# if it is infinite
#

type AlignMinSupportSampler <: ModifyingSampler
	subsampler::DistributionSampler
	function AlignMinSupportSampler(subsampler::DistributionSampler)
		new(subsampler)
	end
end

function sample(s::AlignMinSupportSampler, support)
	delta = support[1] - minimum(s.subsampler.distribution)
	x, trace = sample(s.subsampler, (support[1]-delta, support[2]-delta))
	x + delta, {:sub=>trace, :delta=>delta}
end

amendtrace(s::AlignMinSupportSampler, trace, x) = amendtrace(s.subsampler, trace[:sub], x - trace[:delta])

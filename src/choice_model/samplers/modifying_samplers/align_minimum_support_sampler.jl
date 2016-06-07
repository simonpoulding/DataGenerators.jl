#
# Align Minimum Support Sampler
#
# adds a fixed value to sampled value so that minimum of requested support is aligned to minimum of support of 
# the subsampler
# the subsampler must provide a minimumsupport method
# note: this is intended to be used with distributions with finite minimum support, but no error is explicitly raised
# if it is infinite
#

type AlignMinimumSupportSampler <: ModifyingSampler
	subsampler::Sampler
	function AlignMinimumSupportSampler(subsampler::Sampler)
		new(subsampler)
	end
end

function sample(s::AlignMinimumSupportSampler, support, cc::ChoiceContext)
	delta = support[1] - minimumsupport(s.subsampler)
	x, trace = sample(s.subsampler, (support[1]-delta, support[2]-delta), cc)
	x + delta, Dict{Symbol, Any}(:sub=>trace, :delta=>delta)
end

amendtrace(s::AlignMinimumSupportSampler, trace, x) = amendtrace(s.subsampler, trace[:sub], x - trace[:delta])

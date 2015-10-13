#
# Transforming Sampler
#
# applies a reversible function to the sample
#

type TransformSampler <: ModifyingSampler
  subsampler::Sampler
  fn::Function
  invfn::Function
  function TransformSampler(subsampler::Sampler, fn::Function, invfn::Function)
	  new(subsampler, fn, invfn)
  end
end

function sample(s::TransformSampler, support)
	x, trace = sample(s.subsampler, map(s.invfn, support))
	s.fn(x), Dict{Symbol, Any}(:sub=>trace)
end

amendtrace(s::TransformSampler, trace, x) = amendtrace(s.subsampler, trace[:sub], s.invfn(x))


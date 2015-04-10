#
# Transforming Sampler
#
# applies a reversible function to the sample
#

type TransformingSampler <: ModifyingSampler
  subsampler::Sampler
  fn::Function
  invfn::Function
  function TransformingSampler(subsampler::Sampler, fn::Function, invfn::Function)
	  new(subsampler, fn, invfn)
  end
end

function sample(s::TransformingSampler, support)
	x, trace = sample(s.subsampler, map(s.invfn, support))
	s.fn(x), {:sub=>trace}
end



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

sample(s::TransformingSampler, support::(Real,Real)) = s.fn(sample(s.subsampler, map(s.invfn, support)))



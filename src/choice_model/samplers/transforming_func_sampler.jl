
type TransformingFuncSampler <: TransformingSampler
  subsampler::Sampler
  fn::Function
end

sample(s::TransformingFuncSampler, support) = s.fn(sample(s.subsampler, support))


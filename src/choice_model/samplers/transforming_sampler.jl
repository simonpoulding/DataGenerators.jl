# A transforming sampler allows a function to be applied to the godelnumber sampled
# from a subsampler.
abstract TransformingSampler <: Sampler

numparams(s::TransformingSampler) = numparams(s.subsampler)
setparams(s::TransformingSampler, params::Vector) = setparams(s.subsampler, params)
paramranges(s::TransformingSampler) = paramranges(s.subsampler)
getparams(s::TransformingSampler) = getparams(s.subsampler)
godelnumber(s::TransformingSampler, cc::ChoiceContext) = godelnumber(s.subsampler, cc)

type TransformingFuncSampler <: TransformingSampler
  subsampler::Sampler
  fn::Function
end

function godelnumber(s::TransformingFuncSampler, cc::ChoiceContext)
  s.fn(godelnumber(s.subsampler, cc))::Number
end


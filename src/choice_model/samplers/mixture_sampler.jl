type MixtureSampler <: Sampler
  nparams::Int64           # number of parameters is the domain length (number of values specified in the range)
  samplerdist::Categorical # dist to select among subsamplers
  nsubsamplers::Int64
  subsamplers::Vector{Sampler}
  function MixtureSampler(samplers::Vector, params = Float64[])
    nsubsamplers = length(samplers)
    if length(params) >= nsubsamplers
      ownparams = params[1:nsubsamplers]
    else
      ownparams = ones(nsubsamplers) / nsubsamplers
    end
    samplerdist = categorical_dist_from_vector(ownparams)
    nsubparams = sum(map(numparams, samplers))
    ms = new(nsubsamplers + nsubparams, samplerdist, nsubsamplers, samplers)
    if length(params) == (nsubsamplers + nsubparams)
      set_subsampler_params(samplers, params, nsubsamplers + 1)
    end
    ms
  end
end

categorical_dist_from_vector(v) = Categorical(prob_vector(v))
prob_vector(ary) = ary ./ sum(ary)

function set_subsampler_params(subsamplers::Vector, params::Vector, i::Int64)
  map(subsamplers) do subsampler
    nsubparams = numparams(subsampler)
    setparams(subsampler, params[i:(i+nsubparams-1)])
    i += nsubparams
  end
end

function setparams(s::MixtureSampler, params::Vector)
  assertparamslength(s, params)
  try
    s.samplerdist = categorical_dist_from_vector(params[1:s.nsubsamplers])
  catch err
    @show params[1:s.nsubsamplers]
    throw(err)
  end
  set_subsampler_params(s.subsamplers, params, s.nsubsamplers + 1)
end

function paramranges(s::MixtureSampler)
  [[(0.0, 1.0) for i in 1:s.nsubsamplers]..., map((ss) -> paramranges(ss), s.subsamplers)...]
end

function getparams(s::MixtureSampler)
  res = copy(params(s.samplerdist)[1])
  for subsampler in s.subsamplers
    append!(res, getparams(subsampler))
  end
  res
end

function godelnumber(s::MixtureSampler, cc::ChoiceContext)
  # get the subsampler we should sample
  isubsampler = rand(s.samplerdist)
  subsampler = s.subsamplers[isubsampler]

  # and sample the subsampler
  godelnumber(subsampler, cc)
end

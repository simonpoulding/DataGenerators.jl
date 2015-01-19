MinSigma = 1e-10

# A Gaussian sampler with specified min and max values for the mean and
# a max value for sigma.
type GaussianSampler <: Sampler
  nparams # 2 params, the mean and stddev
  minmean::Float64
  maxmean::Float64
  maxsigma::Float64 # This is max value that sigma is allowed to take. Min is always 0.0.
  dist::Normal
  returnint::Bool # This feels like a kludge but for now...
  function GaussianSampler(minmean = 0.0, maxmean = 1000.0, maxsigma = 100.0, returnint = false)
    new(2, minmean, max(minmean, maxmean), max(MinSigma, maxsigma), Normal(), returnint)
  end
end

function setparams(s::GaussianSampler, params::Vector)
  #@show s
  #println("GaussianSampler.setparams($params)")
  assertparamslength(s, params)
  mu = min(s.maxmean, max(s.minmean, params[1]))
  sig = max(MinSigma, min(s.maxsigma, params[2]))
  s.dist = Normal(mu, sig)
end

paramranges(s::GaussianSampler) = [(s.minmean, s.maxmean), (0.0, s.maxsigma)]

getparams(s::GaussianSampler) = [s.dist.μ, s.dist.σ]

function godelnumber(s::GaussianSampler, cc::ChoiceContext)
  res = rand(s.dist)
  # This is cheating, not sure of solution right now.
  if res < cc.lowerbound
    res = cc.lowerbound
  elseif res > cc.upperbound
    res = cc.upperbound
  end
  s.returnint ? int(res) : res
end

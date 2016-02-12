#
# Poisson Sampler
#
# parameters:
# 	(1) lambda
#

type PoissonSampler <: DiscreteDistributionSampler
	paramranges::Vector{Tuple{Float64,Float64}}
	distribution::Poisson
	function PoissonSampler(params=Float64[])
		s = new([(0.0, maxintfloat(Float64))])
		# the upper limit is arbitrary, but note that typemax(Int) will give rise to InexactError execeptions when
		# sampling, while 0.99*typemax(Int) seems more robust; instead we choose much lower limit of maxintfloat(Float64)
		# on the (very weak) argument that this is consistent with our representation of parameters as Float64
		setparams(s, isempty(params) ? [1.0] : params)
		s
	end
end

function setparams(s::PoissonSampler, params)
	checkparamranges(s, params)
	s.distribution = Poisson(params[1])
end

getparams(s::PoissonSampler) = [s.distribution.λ]

# commented out: use method specified for DistributionSampler
# function estimateparams(s::PoissonSampler, traces)
# 	samples = extractsamplesfromtraces(s, traces)
# 	minnumsamples = 1
# 	if length(samples) >= minnumsamples
# 		s.distribution = fit(typeof(s.distribution), samples)
# 	end
# end

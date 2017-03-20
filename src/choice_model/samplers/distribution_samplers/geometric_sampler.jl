#
# Geometric Sampler
#
# parameters:
# 	(1) p
#
# Note that this interprets p in the same way as the underlying Distributions.Geometric type, i.e.
# values close to 1.0 are unlikely to sample numbers above 0, while values close to 0.0 have samples with a large mean.
# This is the opposite interpretation to the Ruby implementation (and to Boltzmann Dists), and so is NOT the most
# convenient one for modification with the Decay Dist


type GeometricSampler <: DiscreteDistributionSampler
	paramranges::Vector{Tuple{Float64,Float64}}
	distribution::Geometric
	function GeometricSampler(params=Float64[])
		s = new([(0.0, 1.0)])
		setparams!(s, isempty(params) ? [0.5] : params)
		s
	end
end

function setparams!(s::GeometricSampler, params)
	checkparamranges(s, params)
	# parameter of Distribution.Geometric must be in the open interval (0,1), so silently adjust if necessary
	# note nextfloat(0.0), prevfloat(1.0) insufficient adjustment: gives rise to InexactValue error
	p = min(0.99999, max(0.00001, params[1]))
	s.distribution = Geometric(p)
end

getparams(s::GeometricSampler) = [s.distribution.p]

function estimateparams!(s::GeometricSampler, traces)
	samples = extractsamplesfromtraces(s, traces)
	minnumsamples = 1
	if length(samples) >= minnumsamples
		if all(samples.==0)
			# distribution gives error if all samples are 0
			s.distribution = Geometric(0.99999)
		else
			s.distribution = fit(primarydistributiontype(s.distribution), samples)
		end
	end
end

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
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Geometric
	function GeometricSampler(params::Vector{Float64}=Float64[])
		s = new([(0.0, 1.0)])
		setparams(s, isempty(params) ? [0.5] : params)
		s
	end
end

function setparams(s::GeometricSampler, params::Vector{Float64})
	checkparamranges(s, params)
	# parameter of Distribution.Geometric must be in the open interval (0,1), so silently adjust if necessary
	params[1] = min(0.99999, max(0.00001, params[1])) 
	s.params = params
	s.distribution = Geometric(s.params[1])
end


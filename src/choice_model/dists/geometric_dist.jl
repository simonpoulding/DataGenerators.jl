#
# Geometric Distribution
#

# Note that this interprets the one parameter [p] in the same way as the underlying Distributions.Geometric type, i.e.
# values close to 1.0 are unlikely to sample numbers above 0, while values close to 0.0 have samples with a large mean.
# This is the opposite interpretation to the Ruby implementation (and to Boltzmann Dists), and so is NOT the most
# convenient one for modification with the Decay Dist


type GeometricDist <: Dist
	nparams::Int
	params::Vector{Float64}
	distribution::Geometric
	supportlowerbound::Int
	supportlowerquartile::Real
	function GeometricDist()
		d = new(1)
		setparams(d, [0.5])
		d
	end
end

function setparams(d::GeometricDist, params::Vector{Float64})
	assertparamslength(d, params)
	params[1] = min(1.0-1e-5, max(1e-5, params[1])) # parameter of Distribution.Geometric must be in the open interval (0,1), so adjust if necessary
	d.params = params
	d.distribution = Geometric(d.params[1])
	d.supportlowerbound = minimum(d.distribution)
	d.supportlowerquartile = quantile(d.distribution, 0.25)
end

paramranges(d::GeometricDist) = [(0.0, 1.0)]


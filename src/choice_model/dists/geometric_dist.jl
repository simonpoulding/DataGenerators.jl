#
# Geometric Distribution
#

# Note that this interprets the one parameter [p] in the same way as the underlying Distributions.Geometric type, i.e.
# values close to 1.0 are unlikely to sample numbers above 0, while values close to 0.0 have samples with a large mean.
# This is the opposite interpretation to the Ruby implementation (and to Boltzmann Dists), and so is NOT the most
# convenient one for modification with the Decay Dist


type GeometricDist <: DiscreteDist
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Geometric
	supportlowerbound::Int64
	# supportlowerquartile::Real
	function GeometricDist()
		d = new([(0.0, 1.0)])
		assignparams(d, [0.5])
		d
	end
end

function assignparams(d::GeometricDist, params::Vector{Float64})
	# parameter of Distribution.Geometric must be in the open interval (0,1), so silently adjust if necessary
	params[1] = min(0.99999, max(0.00001, params[1])) 
	d.params = params
	d.distribution = Geometric(d.params[1])
	d.supportlowerbound = minimum(d.distribution)
	# d.supportlowerquartile = quantile(d.distribution, 0.25)
end


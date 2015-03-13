#
# Categorical Distribution
#

type CategoricalDist <: DiscreteDist
	numcategories::Int
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Categorical
	supportlowerbound::Int64
	# supportlowerquartile::Float64
	function CategoricalDist(numcategories::Int)
		numcategories >= 1 || error("number of categories must be at least one")
		d = new(numcategories, fill((0.0,1.0), numcategories))
		# Note: could parameterise using number of parameters that is one less than the domain size
		# but there is not an obvious way to do this in a symmetrical way so as not bias any optimisation
		# of the parameters
		assignparams(d, fill(1.0, numcategories))
		d
	end
end

function assignparams(d::CategoricalDist, params::Vector{Float64})
	totalweight = sum(params)
	if totalweight == 0.0
		params = fill(1.0/d.numcategories, d.numcategories)
	elseif totalweight != 1.0
		params = params ./ totalweight
	end
	# TODO we assume that sum of params is close enough (even with rounding errors) to 1.0 to satisfy the Categorical constructor
	# so we do not need handle the rounding errors
	d.params = params
	d.distribution = Categorical(d.params)
	d.supportlowerbound = minimum(d.distribution)
	# d.supportlowerquartile = quantile(d.distribution, 0.25)
end

supportlowerquartile(d::CategoricalDist) = d.supportlowerquartile

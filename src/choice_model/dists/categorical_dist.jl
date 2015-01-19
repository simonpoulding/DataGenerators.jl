#
# Categorical Distribution
#

type CategoricalDist <: Dist
	nparams::Int
	numcategories::Int
	params::Vector{Float64}
	distribution::Categorical
	supportlowerbound::Int
	supportlowerquartile::Real
	function CategoricalDist(numcategories::Int)
		numcategories >= 1 || error("number of categories must be at least one")
		d = new(numcategories, numcategories)
		# Note: could parameterise using number of parameters that is one less than the domain size
		# but there is not an obvious way to do this in a symmetrical way so as not bias any optimisation
		# of the parameters
		setparams(d, fill(1.0/numcategories, numcategories))
		d
	end
end

function setparams(d::CategoricalDist, params::Vector{Float64})
	assertparamslength(d, params)
	totalweight = sum(params)
	if totalweight == 0.0
		params = fill(1.0/d.nparams, d.nparams)
	elseif totalweight != 1.0
		map!((weight)->(weight/totalweight), params)
	end
	# TODO we assume that sum of params is close enough (even with rounding errors) to 1.0 to satisfy the Categorical constructor
	# so we do not need handle the rounding errors
	d.params = params
	d.distribution = Categorical(d.params)
	d.supportlowerbound = minimum(d.distribution)
	d.supportlowerquartile = quantile(d.distribution, 0.25)
end

paramranges(d::CategoricalDist) = fill((0.0,1.0), d.nparams)

supportlowerquartile(d::CategoricalDist) = d.supportlowerquartile

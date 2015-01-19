#
# Discrete Uniform Distribution
#

type DiscreteUniformDist <: Dist
	nparams
	lowerbound::Integer
	upperbound::Integer
	params::Vector{Float64}
	distribution::DiscreteUniform
	supportlowerbound::Integer
	function DiscreteUniformDist(lowerbound::Integer, upperbound::Integer)
		# Distributions.DiscreteUniform assumes an Int, so raise error if outside this range
		# in addition, range typemin(Int) to typemax(Int) causes error in rand(), so for consistency disallow typemin(Int) regardless of upperbound
		lowerbound >= typemin(Int) + 1 || error("lower bound must be no less than $(typemin(Int)+1)")
		upperbound <= typemax(Int) || error("upper bound must be no greater than $(typemax(Int))")
		lowerbound <= upperbound || error("lower bound must not be greater than the upper bound")
		d = new(0, lowerbound, upperbound)
		setparams(d, Float64[])
		d
	end
end

function setparams(d::DiscreteUniformDist, params::Vector{Float64})
	assertparamslength(d, params)
	d.params = params
	d.distribution = DiscreteUniform(d.lowerbound, d.upperbound)
	d.supportlowerbound = minimum(d.distribution)
end

paramranges(d::DiscreteUniformDist) = (Float64,Float64)[]


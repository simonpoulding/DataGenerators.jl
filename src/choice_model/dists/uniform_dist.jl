#
# Uniform Dist
#

type UniformDist <: Dist
	nparams
	lowerbound::Real
	upperbound::Real
	params::Vector{Float64}
	distribution::Uniform
	supportlowerbound::Real
	function UniformDist(lowerbound::Real, upperbound::Real)
 		lowerbound <= upperbound || error("lower bound must not be greater than the upper bound")
		d = new(0, lowerbound, upperbound)
		setparams(d, Float64[])
		d
	end
end

function setparams(d::UniformDist, params::Vector{Float64})
	assertparamslength(d, params)
	d.params = params
	d.distribution = Uniform(d.lowerbound, d.upperbound)
	d.supportlowerbound = minimum(d.distribution)
end

paramranges(d::UniformDist) = (Float64,Float64)[]

# when lowerbound is -Inf, rand(::Distributions.Uniform) returns NaN - fix this here
function sample(d::UniformDist)
	if d.supportlowerbound == -Inf
		if maximum(d.distribution) == Inf
			return (rand() < 0.5) ? -Inf : Inf
		else
			return -Inf
		end
	end
	return rand(d.distribution)
end


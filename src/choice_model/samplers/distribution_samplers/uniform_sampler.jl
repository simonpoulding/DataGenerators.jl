#
# Uniform Dist
#

type UniformDist <: ContinuousDist
	lowerbound::Float64
	upperbound::Float64
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Uniform
	supportlowerbound::Float64
	function UniformDist(lowerbound::Real, upperbound::Real)
		lowerbound <  upperbound || error("lowerbound must be less than upperbound")
		# Distributions.Uniform returns samples of NaN if lower bound is -Inf
		# and (+)Inf if length of domain is more than (approx?) realmax(Float64) ~= 1.79e308
		# therefore limit lower and upper ranges to -/+ realmax(Float64) / 2
		if lowerbound < -realmax(Float64)/2
			warn("lowerbound adjusted to -realmax(Float64)/2")
			lowerbound = -realmax(Float64)/2
		end
		if upperbound > realmax(Float64)/2
			warn("upperbound adjusted to realmax(Float64)/2")
			upperbound = realmax(Float64)/2
		end
		d = new(lowerbound, upperbound, (Float64,Float64)[])
		assignparams(d, Float64[])
		d
	end
end

function assignparams(d::UniformDist, params::Vector{Float64})
	d.params = params
	d.distribution = Uniform(d.lowerbound, d.upperbound)
	d.supportlowerbound = minimum(d.distribution)
end

# TODO should sample actually sample Inf?


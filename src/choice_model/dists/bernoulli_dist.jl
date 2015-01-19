#
# Bernoulli Distribution
#

type BernoulliDist <: Dist
	nparams::Int
	params::Vector{Float64}
	distribution::Bernoulli
	supportlowerbound::Int
	function BernoulliDist()
		d = new(1)
		setparams(d, [0.5])
		d
	end
end

function setparams(d::BernoulliDist, params::Vector{Float64})
	assertparamslength(d, params)
	params[1] = min(1.0, max(0.0, params[1])) 	# the parameter must be in the closed interval [0,1]
	d.params = params
	d.distribution = Bernoulli(d.params[1])
	d.supportlowerbound = minimum(d.distribution)
end

paramranges(d::BernoulliDist) = [(0.0, 1.0)]


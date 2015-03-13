#
# Bernoulli Distribution
#

type BernoulliDist <: DiscreteDist
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Bernoulli
	supportlowerbound::Int64
	function BernoulliDist()
		d = new([(0.0,1.0)])
		assignparams(d, [0.5])
		d
	end
end

function assignparams(d::BernoulliDist, params::Vector{Float64})
	d.params = params
	d.distribution = Bernoulli(d.params[1])
	d.supportlowerbound = minimum(d.distribution)
end



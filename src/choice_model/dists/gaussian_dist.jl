#
# Gaussian Dist
#

type GaussianDist <: ContinuousDist
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Normal
	supportlowerbound::Float64
	function GaussianDist()
		# Distributions.Gaussian returns samples of NaN if mean is -Inf and sigma is Inf
		# therefore limit sigma to realmax(Float64)
		d = new([(-Inf,Inf),(0.0,realmax(Float64))])
		assignparams(d, [0.0, 1.0])
		d
	end
end

function assignparams(d::GaussianDist, params::Vector{Float64})
	params[2] = max(eps(0.0),params[2]) # sigma cannot be exactly 0.0
	d.params = params
	d.distribution = Normal(d.params[1], d.params[2])
	d.supportlowerbound = minimum(d.distribution)
end

# TODO should sample actually sample Inf?


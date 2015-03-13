# a Dist is a probability distribution
abstract Dist
abstract DiscreteDist <: Dist
abstract ContinuousDist <: Dist
# a Dist sits between a sampler of that distribution and the implementation of the distribution (currently the Distributions package)
# the major functionality provided by a dist is setting and getting parameters of the distribution in a consistent manner

#
# The expected interface of a dist is:
#
# numparams(d::dist)
#		- the number of parameters
# setparams(d::dist, params::Vector{Real})
#		- updates the parameters
# paramranges(d::dist)
#		- returns an array specifying the valid ranges for each parameter of the sampler
# getparams(d::dist)
#		- returns the current distribution
# sample(d::dist)
#		- samples a random number from the distributon
# supportlowerbound(d::dist)
#		- the lowest number that will be returned by sampling
#

getparams(d::Dist) = d.params

paramranges(d::Dist) = d.paramranges

numparams(d::Dist) = length(paramranges(d))

sample(d::Dist) = rand(d.distribution)

function setparams(d::Dist, params::Vector{Float64})
	checkparams(d, params)
	assignparams(d, params)
end

function checkparams(d::Dist, params::Vector{Float64})
	nparams = numparams(d)
	length(params) == nparams || error("expected $(nparams) parameters but got $(length(params))")
	pranges = paramranges(d)
	for i in 1:length(pranges)
		prange = pranges[i]
		params[i] >= prange[1] || error("parameter $(i) must be >= $(prange[1]) but was $(params[i])")
		params[i] <= prange[2] || error("parameter $(i) must be <= $(prange[2]) but was $(params[i])")
	end	
end

supportlowerbound(d::Dist) = d.supportlowerbound

include("bernoulli_dist.jl")
include("categorical_dist.jl")
include("discrete_uniform_dist.jl")
include("geometric_dist.jl")
include("uniform_dist.jl")
include("gaussian_dist.jl")


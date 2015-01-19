# a Dist is a probability distribution
abstract Dist
# a Dist sits between a sampler of that distribution and the implementation of the distribution (currently the Distributions package)
# the major functionality provided by a dist is setting and getting parameters of the distribution in a consistent manner

#
# The expected interface of a dist is:
#
#	numparams(d::dist)
#		- the number of parameters
# setparams(d::dist, params::Vector{Real})
#		- updates the parameters
#	paramranges(d::dist)
#		- returns an array specifying the valid ranges for each parameter of the sampler
# getparams(d::dist)
#		- returns the current distribution
# sample(d::dist)
#		- samples a random number from the distributon
# supportlowerbound(d::dist)
#		- the lowest number that will be returned by sampling
#

numparams(d::Dist) = d.nparams

getparams(d::Dist) = d.params

sample(d::Dist) = rand(d.distribution)

assertparamslength(d::Dist, params::Vector{Float64}) =
	length(params) == numparams(d) || error("expected $(numparams(d)) dist parameters, but got $(length(params))")

supportlowerbound(d::Dist) = d.supportlowerbound

include("bernoulli_dist.jl")
include("categorical_dist.jl")
include("discrete_uniform_dist.jl")
include("geometric_dist.jl")
include("uniform_dist.jl")


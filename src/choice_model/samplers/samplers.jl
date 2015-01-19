# A sampler is either a probability distribution on the choice point, or a sampler that modifies other samplers.
abstract Sampler

#
# The expected interface of a sampler is:
#
#	numparams(s::Sampler)
#		- the number parameters (including those of any samplers this sampler modifies)
# setparams(s::Sampler, params::Vector{Real})
#		- updates the parameters of the sampler (if the sampler modifies another, this sets the parameter of both)
#	paramranges(s::Sampler)
#		- returns an array specifying the valid ranges for each parameter of the sampler (if the sampler modifies others, 
#         returns the parameter ranges of the modified sampler as well)
# getparams(s::Sampler)
#		- returns the current parameters (currently used only to default parameters of a modifying sampler)
#	godelnumber(s::Sampler, cc::ChoiceContext)
#		- sample a Gödel number from the sampler
#		- WHILE THE GÖDEL NUMBER NEED NOT RESPECT THE BOUNDS OF THE CHOICE CONTEXT, THE SAMPLER SHOULD DO SO WHEREEVER POSSIBLE
#		- TO AVOID REPEATED SAMPLING

#	Note also that for consistency, samplers allow parameters to be specified in their constructor, but if
# the parameter array is empty, sensible defaults are set instead.  However, this is not required.

# It is assumed that the number of parameters remains constant after construction, and so, for efficiency, 
# samplers can store the number of parameters as a field in the type and use the following method to return the value:

numparams(s::Sampler) = s.nparams

function assertparamslength(s::Sampler, params::Vector)
  if length(params) != numparams(s)
    error("expected $(numparams(s)) sampler parameter(s), but got $(length(params))")
  end
end

# a dist sampler is based directly on a probability distribution in the form a Dist
# therefore many methods at the sampler level simply pass through to the underlying Dist 
abstract DistSampler <: Sampler

numparams(ds::DistSampler) = numparams(ds.dist)

paramranges(ds::DistSampler) = paramranges(ds.dist)

setparams(ds::DistSampler, params::Vector{Float64}) = setparams(ds.dist, params)

getparams(ds::DistSampler) = getparams(ds.dist)

godelnumber(ds::DistSampler,  cc::ChoiceContext) = sample(ds.dist) + cc.lowerbound - ds.dist.supportlowerbound

# The following are DistSamplers
include("bernoulli_sampler.jl")
include("categorical_sampler.jl")
include("discrete_uniform_sampler.jl")
include("geometric_sampler.jl")
include("uniform_sampler.jl")

# Other samplers that modify or combine other samplers
include("gaussian_sampler.jl")
include("mixture_sampler.jl")
include("transforming_sampler.jl")

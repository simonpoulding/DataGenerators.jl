# a sampler is either a probability distribution on the choice point, or a sampler that modifies other samplers.
abstract Sampler

#
# the expected interface of a sampler is:
#
# numparams(s::Sampler)
#		- the number parameters (including those of any samplers this sampler modifies)
# setparams(s::Sampler, params::Vector{Real})
#		- updates the parameters of the sampler (if the sampler modifies another, this sets the parameter of both)
#		- if parameters pass checks on their number and ranges (e.g. using the checkparamranges function below), then
#		  the values should be accommodated in a sensible way even if they break other constraints (a warning may
#         still be raised, though); this is to facilate the use of search on the parameters
# paramranges(s::Sampler)
#		- returns an array specifying the valid ranges for each parameter of the sampler (if the sampler modifies others, 
#         returns the parameter ranges of the modified sampler as well)
#		- the number and range of the parameter are assumed to remain constant even if the params are changed
# getparams(s::Sampler)
#		- returns the current parameters (currently used only to default parameters of a modifying sampler)
# sample(s::Sampler, support, cc::ChoiceContext)
#		- sample a Gödel number from the sampler
#		- samplers need not honour the support constraints; they are provided only to samplers that do take this into account 
# estimateparams(s::Sampler, traces)
#		- estiamte the parameters of the sampler from the passed traces
#
#
# note also that for consistency, samplers allow parameters to be specified in their constructor, but if
# the parameter array is empty, sensible defaults are set instead - however, this is not required
#

# it is assumed that the parameters ranges and number remains constant after construction, and so, these methods
# are provided for convenience:

numparams(s::Sampler) = length(paramranges(s))

# called from setparams to validate passed parameters
function checkparamranges(s::Sampler, params::Vector{Float64})
	pranges = paramranges(s)
	length(params) == length(pranges) || error("expected $(length(pranges)) parameters but got $(length(params))")
	for i in 1:length(pranges)
		prange = pranges[i]
		params[i] >= prange[1] || error("parameter $(i) must be >= $(prange[1]) but was $(params[i])")
		params[i] <= prange[2] || error("parameter $(i) must be <= $(prange[2]) but was $(params[i])")
	end	
end

# identifies whether the sampler supports estimating the model, i.e. setting features other than the parameters, such
# as conditionality on other choice points or on the recursion depth (either of which may change the number of parameters)
supportsconditionalmodelestimation(s::Sampler) = method_exists(estimateconditionalmodel, (typeof(s), Any, Any, Any))


# supports pretty printing
function getsamplertypename(s::Sampler)
	samplertypename = "$(typeof(s))"
	if startswith(samplertypename, "GodelTest.")
		samplertypename = samplertypename[length("GodelTest.")+1:end]
	end
	samplertypename
end


include(joinpath("distribution_samplers", "distribution_sampler.jl"))
include(joinpath("modifying_samplers", "modifying_sampler.jl"))



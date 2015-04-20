#
# SamplerChoiceModel
#

# define abstract sampler type, the type tree of which it is a root, and concrete implementations of these types
include(joinpath("samplers", "sampler.jl"))

# The sampler choice model is a set of samplers, one assigned to each choice point (indexed by choice point id)
type SamplerChoiceModel <: ChoiceModel
	samplers::Dict{Uint, Sampler}
	maxresamplings::Int
end

function SamplerChoiceModel(g::Generator; choicepointmapping::Function=defaultchoicepointmapping, maxresamplings::Int=9)
	samplers = (Uint=>Sampler)[]
	for (cpid, info) in choicepointinfo(g) # gets info from sub-generators also
		samplers[cpid] = choicepointmapping(info)
	end
	maxresamplings >= 0 || ("maxresamplings cannot be negative")
	SamplerChoiceModel(samplers, maxresamplings)
end


function defaultchoicepointmapping(info::Dict)
	cptype = info[:type]
	if cptype == RULE_CP
		sampler = CategoricalSampler(info[:max])
		# justification: expected be a small range, is guaranteed to be closed, and no meaning is attached to order
		# varying support: not possible
	elseif cptype == SEQUENCE_CP
		sampler = AlignMinimumSupportSampler(GeometricSampler())
		# justification: often builds recursive structures, so smaller number of repetitions should be more likely
		# varying support: lower handled by AlignMinimumSupportSampler; upper by rejection sampling
	elseif cptype == VALUE_CP
		datatype = info[:datatype]
		if datatype <: Bool
			sampler = BernoulliSampler()
			# justification: two mutually exclusive outcomes, so natural choice
			# varying support: not possible
		elseif datatype <: Integer # order of if clauses matters here since Bool <: Integer
			sampler = AdjustParametersToSupportSampler(DiscreteUniformSampler())
			# justification: simplicity
			# varying support: range of distribution is dynamically modified using AdjustParametersToSupport
		else # floating point, but may also be a rational type
			sampler = AdjustParametersToSupportSampler(UniformSampler())
			# justification: simplicity
			# varying support: range of distribution is dynamically modified using AdjustParametersToSupport
		end
	else
		error("unrecognised choice point type when creating sampler choice model")
	end
	sampler
end


#
# GodelTest interface
#

# retrieve the sampler for this choice point and then ask it to return a godel number
# resample if necessary - usually because upperbound cannot be enforced directly by sampler,
# but eventually fall back to uniform distribution
function godelnumber(cm::SamplerChoiceModel, cc::ChoiceContext)
	lowerbound = isfinite(cc.lowerbound) ? cc.lowerbound : sign(cc.lowerbound) * realmax(Float64)
	upperbound = isfinite(cc.upperbound) ? cc.upperbound : sign(cc.upperbound) * realmax(Float64)
	sampler = cm.samplers[cc.cpid]
	for samplecount in 0:cm.maxresamplings
		x, trace = sample(sampler, (lowerbound, upperbound))
		if lowerbound <= x <= upperbound
			return x, trace
		end
	end
	warn("falling back to a uniform distribution after too many resamplings in sampler choice model")
	if cc.datatype <: Integer # includes Bool
		fallbacksampler = DiscreteUniformSampler([lowerbound, upperbound])
	elseif cc.datatype <: FloatingPoint
		fallbacksampler = UniformSampler([lowerbound, upperbound])
	else
		@assert false
	end
	fallbackx, fallbacktrace = sample(fallbacksampler, (lowerbound, upperbound))
	# we use the last trace form the 'proper' sampler but place in it this fallback sampled value
	amendtrace(sampler, trace, fallbackx)
	return fallbackx, trace
end


#
# Methods applied to the model as a whole (in order to apply search)
#

# Note: paramranges, setparams and getparams the following assumption: the iteration order of values from
# the samplers dictionary remains consistent (it need not be the order in which entries are initially specified)

# get total number of sampler parameters
numparams(cm::SamplerChoiceModel) = sum(map((sampler)->numparams(sampler), values(cm.samplers)))

# get parameter ranges for all samplers
function paramranges(cm::SamplerChoiceModel)
	ranges = (Float64,Float64)[]
	for sampler in values(cm.samplers)
		ranges = [ranges, paramranges(sampler)]
	end
	ranges
end

# set parameters of all samplers
function setparams(cm::SamplerChoiceModel, params)
	params = convert(Vector{Float64},params)
	if length(params) != numparams(cm)
		error("expected $(numparams(cm)) model parameter(s), but got $(length(params))")
	end
	idx = 1
	for sampler in values(cm.samplers)
		nparams = numparams(sampler)
		# TODO replace this with a check on getnummodelparams
		@assert (idx+nparams-1)<=length(params)
		setparams(sampler, params[idx:(idx+nparams-1)])
		# note: it is important here that sampler works on a copy of the parameters (which is ensured by [range] syntax)
		# as the sampler may adjust its parameters
		idx += nparams
	end
end

# get parameters of all samplers
function getparams(cm::SamplerChoiceModel)
	params = (Float64)[]
	for sampler in values(cm.samplers)
		params = [params, getparams(sampler)]
	end
	params
end



#
# SamplerChoiceModel
#

# define abstract sampler type, the type tree of which it is a root, and concrete implementations of these types
include(joinpath("samplers", "sampler.jl"))

# The sampler choice model is a set of samplers, one assigned to each choice point (indexed by choice point id)
type SamplerChoiceModel <: ChoiceModel
	samplers::Dict{UInt, Sampler}
	maxresamplings::Int
end

function SamplerChoiceModel(g::Generator; choicepointmapping::Function=defaultchoicepointmapping, maxresamplings::Int=9)
	samplers = Dict{UInt, Sampler}()
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
	fallback = true
	x, trace = nothing, nothing
	samplecount = 0
	while (samplecount <= cm.maxresamplings) && (fallback)
		x, trace = sample(sampler, (lowerbound, upperbound), cc::ChoiceContext)
		if lowerbound <= x <= upperbound
			fallback = false
		end
		samplecount += 1
	end
	if fallback
		warn("falling back to a uniform distribution after too many resamplings in sampler choice model")
		if cc.datatype <: Integer # includes Bool
			fallbacksampler = DiscreteUniformSampler([lowerbound, upperbound])
		elseif cc.datatype <: AbstractFloat
			fallbacksampler = UniformSampler([lowerbound, upperbound])
		else
			@assert false
		end
		x, trace = sample(fallbacksampler, (lowerbound, upperbound))
		# we use the last trace form the 'proper' sampler but place in it this fallback sampled value
		amendtrace(sampler, trace, x)
	end
	return x, Dict(:gdl=>x, :sam=>trace, :fbk=>fallback)
end


# Note: paramranges, setparams and getparams the following assumption: the iteration order of values from
# the samplers dictionary remains consistent (it need not be the order in which entries are initially specified)

# get parameter ranges for all samplers
function paramranges(cm::SamplerChoiceModel)
	ranges = Tuple{Float64,Float64}[]
	for sampler in values(cm.samplers)
		ranges = [ranges; paramranges(sampler)]
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
		params = [params; getparams(sampler)]
	end
	params
end

# extract dict of trace info indexed by cpid from a vector of cm traces
function extractsamplertracesbycp(cm::SamplerChoiceModel, cmtraces)
	samplertracesbycp = Dict{UInt,Vector{Dict}}()
	for cmtrace in cmtraces
		for (cpid, trace) in cmtrace
			if !haskey(samplertracesbycp, cpid)
				samplertracesbycp[cpid] = Dict[]
			end
			push!(samplertracesbycp[cpid], trace[:sam])
		end
	end
	samplertracesbycp
end

# estimate the parameters of each sampler based on vector of traces from generation states
function estimateparams(cm::SamplerChoiceModel, cmtraces)
	samplertracesbycp = extractsamplertracesbycp(cm, cmtraces)
	for (cpid, sampler) in cm.samplers
		if haskey(samplertracesbycp, cpid)
			estimateparams(sampler, samplertracesbycp[cpid])
		end
	end
end


# at each cp in every trace, record the most recent gn emitted by every choice point (i.e. a "history")
# store this by cpid
# for ease of use in re-estimating sampler, we simultaneously extract sampler traces for each history
function extractgnhistoriesbycp(cm::SamplerChoiceModel, cmtraces)
	
	cpids = collect(keys(cm.samplers))
	# we use cpid vector this to define indices of gns in the histories in order to avoid costly associative arrays for the histories
	numcps = length(cpids)
	# provide quick lookup of index given cpid
	cpindexlookup = Dict{UInt, UInt}()
	for i in 1:numcps
		cpindexlookup[cpids[i]] = i
	end
	# process each trace
	gnhistoriesbycp = Dict{UInt, Vector{Vector{Any}}}()
	samplertracesbycp = Dict{UInt, Vector{Dict}}()
	for cmtrace in cmtraces
		currenthistory =  convert(Vector{Any}, fill(nothing, numcps))
		for cptrace in cmtrace
			(cpid, trace) = cptrace
			# store (copy of) current history by cpid and its Gödel number
			if !haskey(gnhistoriesbycp, cpid)
				gnhistoriesbycp[cpid] = Vector{Vector{Any}}()
			end
			gn = trace[:gdl]
			# add Gödel number as *last* element
			push!(gnhistoriesbycp[cpid], [currenthistory; gn]) # this also causes implicit copy
			# now update history with this choice point's Gödel number
			currenthistory[cpindexlookup[cpid]] = trace[:gdl]
			# also store trace for this sampler (so in the same order as the history)
			if !haskey(samplertracesbycp, cpid)
				samplertracesbycp[cpid] = Vector{Dict}()
			end
			push!(samplertracesbycp[cpid], trace[:sam])
		end
	end
	cpids, gnhistoriesbycp, samplertracesbycp
end

# 
# 
# consider node A which has r distinct values
# par(A) are parents of A, which have q is distinct instantions of parents
# N_ij is number of cases where A takes i^th value and parents take j^th value (N_.j is sum of this over i)
# then:
#   log K2[A|par(A)] = sum_j=1^q log[(r-1)! / (N_.j + r -1)!] + sum_j=1^q sum_i=1^r log[N_ij!]
# 

function estimatebayesianmodel(cm::SamplerChoiceModel, cmtraces)
	
	# extract the history (the most recent value of all choice points) at each choice point invocation in all traces
	(cpids, gnhistoriesbycp, samplertracesbycp) = extractgnhistoriesbycp(cm, cmtraces)
	
	# process each cp
	# TODO PARALLELISE!!!
	for cpid in cpids

		# TODO: numparams?
		if method_exists(estimatebayesianmodel, (typeof(cm.samplers[cpid]), Any, Any, Any))
			estimatebayesianmodel(cm.samplers[cpid], cpids, gnhistoriesbycp[cpid], samplertracesbycp[cpid])
		else
			estimateparams(cm.samplers[cpid], samplertracesbycp[cpid])
		end
		
	end
	
end
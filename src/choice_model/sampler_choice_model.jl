#
# SamplerChoiceModel
#
import Base.show

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
	maxresamplings >= 0 || error("maxresamplings cannot be negative")
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
			fallbacksampler = DiscreteUniformSampler([float(lowerbound), float(upperbound)])
		elseif cc.datatype <: AbstractFloat
			fallbacksampler = UniformSampler([lowerbound, upperbound])
		else
			@assert false
		end
		x, fallbacktrace = sample(fallbacksampler, (lowerbound, upperbound), cc::ChoiceContext)
		# we use the last trace form the 'proper' sampler but place in it this fallback sampled value
		amendtrace(sampler, trace, x)
	end
	cptrace = Dict(:sam=>trace, :fbk=>fallback)
	# some overhead to recording both the following, so could control using model-level parameters
	cptrace[:acs] = getimmediateancestorcpseqnumber(cc.derivationstate)
	cptrace[:rcd] = getcurrentrecursiondepth(cc.derivationstate)
	return x, cptrace
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
	for cpid in keys(samplertracesbycp)
		estimateparams(cm.samplers[cpid], samplertracesbycp[cpid])
	end
end


# at each cp in every trace, record the most recent gn emitted by every choice point (i.e. a "history")
# store this by cpid
# for ease of use in re-estimating sampler params, we simultaneously extract sampler traces for each history
function extractgnhistoriesbycp(cm::SamplerChoiceModel, cmtraces, recencywindow::Int, distinguishparentsbyrecursiondepth::Bool, restricttoancestors::Bool)
	
	# current history values at recent choice point, distinguised by recency (up to recencywindow)
	# note: to avoid creating unused cplabels (cp instances distinguished by recency, and optionally recursion depth),
	# that the model estimation code must neverthless process, we build up the cplabels as we go, and 
	# then later pad to histories to the full length once all traces have been processed
	# note also: the last entry in each history is the current godel number
	
	# tuples that label each index in the history vector: tuple is (cpid, recursiondepth, recency, restricttoancestors)
	cplabels = Vector{Tuple{UInt, Any, Int, Bool}}() # Any is type of recursion depth since this is set to nothing if it is not required
	# provides quick lookup of index given a cplabel
	cplabelidxlookup = Dict{Tuple{UInt, Any, Int, Bool}, Int}()
	
	# process each trace
	gnhistoriesbycp = Dict{UInt, Vector{Vector{Any}}}()
	samplertracesbycp = Dict{UInt, Vector{Dict}}()
	
	# ... we do this in different ways depending on whether we need to restrict the history to ancestors or not;
	# in the former case, we can't keep a "running" history, but instead must re-evaluate the history each time 
	# in order to filter according to ancestry
	
	if restricttoancestors

		for cmtrace in cmtraces
			
			for i in 1:length(cmtrace) # consider each choice point in trace in turn
				
				(currentcpid, currenttrace) = cmtrace[i]
				history = convert(Vector{Any}, fill(nothing, length(cplabels)))
				
				# we can traverse back through ancestor choice points using the ancestor sequence numbers stored in the trace
				ancestorcpseqnumber = currenttrace[:acs]
				while ancestorcpseqnumber != nothing

					(earliercpid, earliertrace) = cmtrace[ancestorcpseqnumber]
					
					earlierrecursiondepth = distinguishparentsbyrecursiondepth ? earliertrace[:rcd] : nothing
					
					# now, look for recency entry that has not yet been filled
					recency, historyrecorded = 1, false
					while (recency <= recencywindow) && (!historyrecorded)
						hidx = get(cplabelidxlookup, (earliercpid, earlierrecursiondepth, recency, restricttoancestors), 0)
						if hidx > 0
							if history[hidx] == nothing
								history[hidx] = earliertrace[:gdl]
								historyrecorded = true
							end
						else
							push!(history, earliertrace[:gdl])
							historyrecorded = true
							push!(cplabels, (earliercpid, earlierrecursiondepth, recency, restricttoancestors))
							cplabelidxlookup[(earliercpid, earlierrecursiondepth, recency, restricttoancestors)] = length(cplabels)
						end
						recency += 1
					end
					
					ancestorcpseqnumber = earliertrace[:acs]
					
				end # ancestor choice points
				
				if !haskey(gnhistoriesbycp, currentcpid)
					gnhistoriesbycp[currentcpid] = Vector{Vector{Any}}()
				end
				# add current Gödel number as *last* element
				push!(gnhistoriesbycp[currentcpid], [history; currenttrace[:gdl]]) # this concatenation also causes implicit copy
				
				# also store trace for this sampler (so in the same order as the history)
				if !haskey(samplertracesbycp, currentcpid)
					samplertracesbycp[currentcpid] = Vector{Dict}()
				end
				push!(samplertracesbycp[currentcpid], currenttrace[:sam])
				
			end # each choice point
			
		end # each trace
		
	else
		
		for cmtrace in cmtraces
			
			# in this case (without filtering by ancestry) we can build up the history
			# as we process each choice point in chronoligical order
			runninghistory = convert(Vector{Any}, fill(nothing, length(cplabels)))
			
			for cptrace in cmtrace
				
				(cpid, trace) = cptrace
				
				# store (copy of) running history against this cpid
				if !haskey(gnhistoriesbycp, cpid)
					gnhistoriesbycp[cpid] = Vector{Vector{Any}}()
				end
				gn = trace[:gdl]
				# add current Gödel number as *last* element
				push!(gnhistoriesbycp[cpid], [runninghistory; gn]) # this concatenation also causes implicit copy
				
				recursiondepth = distinguishparentsbyrecursiondepth ? trace[:rcd] : nothing
				
				# now update history with this choice point's Gödel number
				# first shift down values at other recencies
				hidx = get(cplabelidxlookup, (cpid, recursiondepth, recencywindow, restricttoancestors), 0)
				for recency in (recencywindow-1):-1:1
					newerhidx = get(cplabelidxlookup, (cpid, recursiondepth, recency, restricttoancestors), 0)
					@assert (newerhidx != 0) || (hidx == 0) # if no label for current recency, then can't be one for an older recency
					if newerhidx > 0
						if hidx > 0
							runninghistory[hidx] = runninghistory[newerhidx]
						else
							push!(runninghistory, runninghistory[newerhidx])
							push!(cplabels, (cpid, recursiondepth, recency+1, restricttoancestors))
							cplabelidxlookup[(cpid, recursiondepth, recency+1, restricttoancestors)] = length(cplabels)
						end
					end
					hidx = newerhidx
				end
				# and then store current Gödel number at recency 1
				if hidx > 0
					runninghistory[hidx] = trace[:gdl]
				else
					push!(runninghistory, trace[:gdl])
					push!(cplabels, (cpid, recursiondepth, 1, restricttoancestors))
					cplabelidxlookup[(cpid, recursiondepth, 1, restricttoancestors)] = length(cplabels)
				end
				
				# also store trace for this sampler (so in the same order as the history)
				if !haskey(samplertracesbycp, cpid)
					samplertracesbycp[cpid] = Vector{Dict}()
				end
				push!(samplertracesbycp[cpid], trace[:sam])
				
			end # each choice point
			
		end # each trace
		
	end
	
	# now pad histories so they are all the same length (which should be cplabels + 1 since first entry is actually gn of cp at 
	# time the history was taken
	targetlength = length(cplabels) + 1
	for gnhistories in values(gnhistoriesbycp)
		for gnhistory in gnhistories
			padlength = targetlength - length(gnhistory)
			@assert padlength >= 0
			if padlength > 0
				# current gn was recorded as the last entry at the time of location, so remove and then add again after padding
				currentgn = pop!(gnhistory)
				append!(gnhistory, fill(nothing, padlength))
				push!(gnhistory, currentgn)
			end 
		end
	end

	cplabels, gnhistoriesbycp, samplertracesbycp

end


function estimateconditionalmodel(cm::SamplerChoiceModel, cmtraces; recencywindow::Int = 1, distinguishparentsbyrecursiondepth::Bool = false, restricttoancestors::Bool=false)
	
	recencywindow >= 1 || error("recency window cannot be less than 1")
	
	# extract the history (the most recent value of all choice points) at each choice point invocation in all traces
	cplabels, gnhistoriesbycp, samplertracesbycp = extractgnhistoriesbycp(cm, cmtraces, recencywindow, distinguishparentsbyrecursiondepth, restricttoancestors)
	
	# process each cp
	# TODO PARALLELISE!!!
	for cpid in keys(samplertracesbycp)
		# note: if samplertracsbycp has an entry for cpid, then so will gnhistoriesbycp
		if supportsconditionalmodelestimation(cm.samplers[cpid])
			estimateconditionalmodel(cm.samplers[cpid], cplabels, gnhistoriesbycp[cpid], samplertracesbycp[cpid])
		else
			estimateparams(cm.samplers[cpid], samplertracesbycp[cpid])
		end
	end
		
end

# pretty print the model

function show(io::IO, cm::SamplerChoiceModel)

	# now changed this method to override show, can no longer pass generator (TODO: could include ref to generator in cm)
	# # first build slightly more informative names for choice points
	# cpnames = Dict{UInt, AbstractString}()
	# cpinfos = choicepointinfo(g)
	# orderedcpids = sort(collect(keys(cpinfos)))
	# for cpid in orderedcpids
	# 	cpinfo = cpinfos[cpid]
	# 	cpname = "($(cpid))"
	# 	cptype = cpinfo[:type]
	# 	if cptype == RULE_CP
	# 		cpname = "Rule $(cpinfo[:rulename]) " * cpname
	# 	elseif cptype == SEQUENCE_CP
	# 		cpname = "Sequence " * cpname
	# 	elseif cptype == VALUE_CP
	# 		cpname = "Value $(cpinfo[:datatype]) " * cpname
	# 	end
	# 	cpnames[cpid] = cpname
	# end
	
	# now print samplers in id order (which should (roughly) be lexical order of choice points?)
	for cpid in sort(collect(keys(cm.samplers)))
		print(io, "$(hex(cpid)): ")
		show(io, cm.samplers[cpid])
	end
	
end
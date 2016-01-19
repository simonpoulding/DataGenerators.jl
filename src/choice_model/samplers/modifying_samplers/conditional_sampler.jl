#
# Conditional Sampler
#
# chooses sampler based on values of a parent choice point
#
# implementation notes:
# 	* to facilitate EDAs using model-building (i.e. selection of parents), we implicitly constrain all the underlying samplers
# 	  to be of the same type (i.e. only the parameters differ)
# 	* we permit only one parent to be specified; to support models with multiple parents, the samplers can be nested:
#     ConditionalSampler(ConditionalSampler, ...)
#   * we permit parentcpid to be passed as "nothing" (which in effect makes the sampler unconditional as it simply calls the specified default sampler)
#     since often the parent cpid may not be known when the sampler is initially constructed.
#

type ConditionalSampler <: ModifyingSampler
	defaultsampler::Sampler
	parentcpid
	conditionalsamplers::Dict{Any,Sampler}  # TODO: type of key is really Union{Real,Void} (since parent gns can be "nothing") rather than Any - is it worth specifying?
	function ConditionalSampler(defaultsampler::Sampler, parentcpid=nothing, parentgns=Vector{Real}(),  conditionalparams=Vector{Vector{Float64}}())
		# default parentcpid of nothing is for ease of construction as parent cpids may not be known at construction time
		# it turns the sampler into a non-conditional sampler
		(parentcpid != nothing) || isempty(parentgns) || error("Parent Gödel number cannot be specified if no parent cpid is given ")
		length(parentgns) >= length(conditionalparams) || error("More conditional parameter settings specified than parent Gödel numbers")
		conditionalsamplers = Dict{Any,Sampler}()
		for i in 1:length(parentgns)
			!haskey(conditionalsamplers, parentgns[i]) || error("Parent Gödel number is specified more than once")
			conditionalsampler = deepcopy(defaultsampler)
			# if params are specified, then set them, otherwise use default parameters
			if i <= length(conditionalparams)
				setparams(conditionalsampler, conditionalparams[i])
			end
			conditionalsamplers[parentgns[i]] = conditionalsampler
		end
		new(defaultsampler, parentcpid, conditionalsamplers)
	end
end

# note: in the following methods, we could make assumption that numparams for each conditional sampler is the same as default sampler
# (which is what the constructor enforces), but where possible (generally, without too much of a performance impact) we avoid this assumption
# so that the code is a little more robust

# note: the code assumes that order of samplers returned by values(conditionalsamplers) is stable

# numparams(s::ConditionalSampler) = numparams(s.defaultampler) + sum(numparams, s.conditionalsamplers)

function paramranges(s::ConditionalSampler)
	pr = paramranges(s.defaultsampler)
	for conditionalsampler in values(s.conditionalsamplers)
		pr = [pr; paramranges(conditionalsampler)]
	end
	pr
end

function setparams(s::ConditionalSampler, params)
	nparams = numparams(s)
	length(params) == nparams || error("expected $(nparams) parameters but got $(length(params))")
	paramstart = 1
	paramcount = numparams(s.defaultsampler)
	setparams(s.defaultsampler, params[paramstart:(paramstart+paramcount-1)])
	for conditionalsampler in values(s.conditionalsamplers)
		paramstart += paramcount
		paramcount = numparams(conditionalsampler)
		setparams(conditionalsampler, params[paramstart:(paramstart+paramcount-1)])
	end
end

function getparams(s::ConditionalSampler)
	ps = getparams(s.defaultsampler)
	for conditionalsampler in values(s.conditionalsamplers)
		ps = [ps; getparams(conditionalsampler)]
	end
	ps
end

function sample(s::ConditionalSampler, support, cc::ChoiceContext)
	# extract Gödel number of parent choice point at its most recent invocation
	parentgn = nothing
	if s.parentcpid != nothing
		parentindex = indexin([s.parentcpid], map(t->t[1], cc.derivationstate.cmtrace))
		# first element in each cmtrace element is the cpid
		# indexin returns the *highest* (i.e. most recent in godel sequence) for each parentcpid (or 0 otherwise)
		if parentindex[1] > 0 
			parentgn = cc.derivationstate.cmtrace[parentindex[1]][2][:gdl] # in trace (second element in tuple), godelnumber is stored with key :gdl at top level
			@assert parentgn == cc.derivationstate.godelsequence[parentindex[1]]
		end
	end
	# if there is a sampler specified for the parent value, then use it, otherwise revert to default
	if (s.parentcpid != nothing) && (haskey(s.conditionalsamplers, parentgn))
		x, trace = sample(s.conditionalsamplers[parentgn], support, cc)
	else
		x, trace = sample(s.defaultsampler, support, cc)
	end
	x, Dict{Symbol, Any}(:par=>parentgn, :sub=>trace)
end

# TODO for consistency with other sub-sampler, we attempt re-estimation for all 
# subsamplers, if we can tell then have too few (or no) traces here: we let the sub-sampler decide what
# to do in this situation.  This may be a (small?) performance overhead
#
# NOTE: if model is changed (i.e. a different parent is identified), then traces will be invalid
# and this method must NOT be used
#
function estimateparams(s::ConditionalSampler, traces)
	# first divide out the traces according to which subsampler was used
	defaultsamplertraces = Vector{Dict}()
	conditionalsamplertraces = Dict{Any,Vector{Dict}}()
	for parentgn in keys(s.conditionalsamplers)
		conditionalsamplertraces[parentgn] = Vector{Dict}()
	end
	for trace in traces
		parentgn = trace[:par]
		if haskey(s.conditionalsamplers, parentgn)
			push!(conditionalsamplertraces[parentgn], trace[:sub])
		else
			push!(defaultsamplertraces, trace[:sub])
		end
	end
	# then re-estimate the subsamplers
	estimateparams(s.defaultsampler, defaultsamplertraces)
	for parentgn in keys(s.conditionalsamplers)
		estimateparams(s.conditionalsamplers[parentgn], conditionalsamplertraces[parentgn])
	end
end

function amendtrace(s::ConditionalSampler, trace, x)
	parentgn = trace[:par]
	if haskey(s.conditionalsamplers, parentgn)
		amendtrace(s.conditionalsamplers[parentgn], trace[:sub], x)
	else
		amendtrace(s.defaultsampler, trace[:sub], x)
	end
end


function determineparentusingK2(s::ConditionalSampler, cpids, gnhistories)
	
	numhistories = length(gnhistories)
	# the history for the current cp (i.e. "node A") which is the last value in each history
	ahistory = map(x->x[end], gnhistories)
	# A_values are values that current cp takes
	avalues = unique(ahistory)
	# println("A takes values: $(avalues)")
	r = length(avalues)
	# println("Therefore r is: $(r)")
	lfactrminus1 = lfact(r-1)

	# calculate value for no parent (effectively a parent taking all the same value)
	bestparindices = Any[nothing]
	bestlogK2 = lfactrminus1 - lfact(numhistories + r - 1)
	for i in 1:r
		Ni = count(x->x==avalues[i], ahistory)
		bestlogK2 += lfact(Ni)
	end
	# println("No parent gives a K2 value of: $(bestlogK2)")
	
	# consider each possible parent in turn
	for parindex in 1:length(cpids)
		# println("Considering potential parent #$(parindex) ...")
		
		# the history of the i^th possible parent is the i^th entry
		parhistory = map(x->x[parindex], gnhistories)
		parvalues = unique(parhistory)
		# println("par(A) takes values: $(parvalues)")
		q = length(parvalues)
		# println("Therefore q is: $(q)")
		
		logK2 = 0.0
		
		for j in 1:q
			Ndotj = count(x->x==parvalues[j], parhistory)
			# println("For j=$(j), N_.j is: $(Ndotj)")
			logK2 += lfactrminus1 - lfact(Ndotj + r - 1)
			# lfact is log factorial approximation
			# TODO: since current always integer, could do a lookup
			
			for i in 1:r
				Nij = count(k->((ahistory[k]==avalues[i]) && (parhistory[k]==parvalues[j])), 1:numhistories)
				# println("For j=$(j), i=$(i), N_ij is: $(Nij)")
				logK2 += lfact(Nij)
			end
			
		end
		
		# println("Potential parent $(parindex) has logK2 of: $(logK2)")
		if logK2 > bestlogK2
			# strictly greater than so simplicitly of network is encouraged
			bestparindices = [parindex]
			bestlogK2 = logK2
		elseif logK2 == bestlogK2
			push!(bestparindices, parindex)
		end
		
	end
	
	(nothing in bestparindices) ? nothing : bestparindices[rand(1:length(bestparindices))]
	
end

function estimatebayesianmodel(s::ConditionalSampler, cpids, gnhistories, traces)
	
	# assign new parent
	parindex = determineparentusingK2(s, cpids, gnhistories)
	s.parentcpid = (parindex == nothing) ? nothing : cpids[parindex]

	# println("******* New parent cpid is index $(parindex) : $(s.parentcpid)")

	# defaultsampler
	# TODO, if there is a parent, since we will account for all values of the parents, there is nothing left
	# to estimate the default: what to do? Currently we do this for all ...
	
	# we use the following to filter cpids and histories passed to any sub-sampler to remove the chosen cpid
	cpmask = convert(Vector{Bool}, map(c->c!=parindex, 1:length(cpids)))
	historymask = [cpmask; true]
	# we add a true to the cpmask to retain final value which is the current cp Gödel number
	
	defaulttraces = map(t->t[:sub], traces)	
	if method_exists(estimatebayesianmodel, (typeof(s.defaultsampler), Any, Any, Any))
		# pass all histories and traces to default sampler
		defaultgnhistories = map(h->h[historymask], gnhistories)
		estimatebayesianmodel(s.defaultsampler, cpids[cpmask], defaultgnhistories, defaulttraces)
	else
		estimateparams(s.defaultsampler, defaulttraces)
	end

	if parindex != nothing
		
		# if parent identified, create and estimate a sampler for each parent values

		s.conditionalsamplers = Dict{Any,Sampler}()

		parhistory = map(x->x[parindex], gnhistories)
		parvalues = unique(parhistory)
		
		for parvalue in parvalues
			
			conditionalsampler = deepcopy(s.defaultsampler)
			s.conditionalsamplers[parvalue] = conditionalsampler
						
			parentvaluemask = convert(Vector{Bool}, map(v->v==parvalue, parhistory))
			# we use the history to determine which histories are relevant
			# note: we can't use the parent value stored with the trace since the parent may have changed
		
			conditionaltraces = map(x->x[:sub], traces[parentvaluemask])
			if method_exists(estimatebayesianmodel, (typeof(conditionalsampler), Any, Any, Any))				
				# pass histories and traces filtered by mask where parent value matches the condition on the sampler
				# we also filter the histories to remove parent index just chosen
				conditionalgnhistories = map(h->h[historymask], gnhistories[parentvaluemask])
				# println("<<<<<<< START nested")
				estimatebayesianmodel(conditionalsampler, cpids[cpmask], conditionalgnhistories, conditionaltraces)
				# println("<<<<<<< END nested")
			else
				estimateparams(conditionalsampler, conditionaltraces)				
			end
			
		end

	end

end
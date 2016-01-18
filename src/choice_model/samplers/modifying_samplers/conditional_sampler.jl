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
		@assert length(cc.derivationstate.cmtrace) == length(cc.derivationstate.godelsequence)
		# TODO change code (and remove assert) if we add GN to trace
		parentindex = indexin([s.parentcpid], map(t->first(t), cc.derivationstate.cmtrace))
		# first element in each cmtrace element is the cpid
		# indexin returns the *highest* (i.e. most recent in godel sequence) for each parentcpid (or 0 otherwise)
		if parentindex[1] > 0 
			parentgn = cc.derivationstate.godelsequence[parentindex[1]]
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
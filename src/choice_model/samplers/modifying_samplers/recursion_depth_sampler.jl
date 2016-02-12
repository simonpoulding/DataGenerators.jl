#
# Recursion Depth Sampler
#
# chooses sampler based on recursion depth, which we define as the number of times a rule appears
# in the stack of rules (the depth of the rule instance containing this current choice point
# must therefore be 1 or greater)
#
# implementation notes:
# 	* we implicitly constrain all the underlying samplers to be of the same type (i.e. only the parameters differ)
#	* so that number of model parameters does not change, a maximum depth must be specified: any deeper depth uses the sampler
#	  at this maximum depth
#

type RecursionDepthSampler <: ModifyingSampler
	depthsamplers::Vector{Sampler}
	function RecursionDepthSampler(basesampler::Sampler, maxdepth::Int=1, depthparams=Vector{Float64}[])
		(maxdepth > 0) || error("Max depth must be 1 or more")
		depthsamplers = Sampler[]
		for d in 1:maxdepth
			depthsampler = deepcopy(basesampler)
			if d <= length(depthparams)
				setparams(depthsampler, depthparams[d])
			end
			push!(depthsamplers, depthsampler)
		end
		new(depthsamplers)
	end
end

# note: in the following methods, we could make assumption that numparams for each depth sampler is the same as base sampler
# (which is what the constructor enforces), but where possible (generally, without too much of a performance impact) we avoid this assumption
# so that the code is a little more robust

function paramranges(s::RecursionDepthSampler)
	pr = Tuple{Float64,Float64}[]
	for depthsampler in s.depthsamplers
		pr = [pr; paramranges(depthsampler)]
	end
	pr
end

function setparams(s::RecursionDepthSampler, params)
	nparams = numparams(s)
	length(params) == nparams || error("expected $(nparams) parameters but got $(length(params))")
	paramstart = 1
	paramcount = 0
	for depthsampler in s.depthsamplers
		paramstart += paramcount
		paramcount = numparams(depthsampler)
		setparams(depthsampler, params[paramstart:(paramstart+paramcount-1)])
	end
end

function getparams(s::RecursionDepthSampler)
	ps = Float64[]
	for depthsampler in s.depthsamplers
		ps = [ps; getparams(depthsampler)]
	end
	ps
end

function sample(s::RecursionDepthSampler, support, cc::ChoiceContext)
	# get recursion depth of rule instance containing the current choice point
	recursiondepth = getcurrentrecursiondepth(cc.derivationstate)
	depth = min(recursiondepth, length(s.depthsamplers))
	@assert depth >= 1
	x, trace = sample(s.depthsamplers[depth], support, cc)
	x, Dict{Symbol, Any}(:dep=>depth, :rcd=>recursiondepth, :sub=>trace) # :dep records the *truncated* depth, i.e. the actual index of the subsampler used, while :rcd records the actual recursion depth
end

# TODO for consistency with other sub-sampler, we attempt re-estimation for all 
# subsamplers, if we can tell then have too few (or no) traces here: we let the sub-sampler decide what
# to do in this situation.  This may be a (small?) performance overhead
#
function estimateparams(s::RecursionDepthSampler, traces)
	# first divide out the traces according to the depth used
	depthsamplertraces = Vector{Vector{Dict}}()

	# can't use fill here as all entries would refer to the same empty array of traces object
	for d in 1:length(s.depthsamplers)
		push!(depthsamplertraces, Vector{Dict}())
	end

	for trace in traces
		depth = trace[:dep]
		push!(depthsamplertraces[depth], trace[:sub])
	end
	
	for d in 1:length(s.depthsamplers)
		estimateparams(s.depthsamplers[d], depthsamplertraces[d])
	end
	
end


function estimateconditionalmodel(s::RecursionDepthSampler, cplabels, gnhistories, traces)

	# we approach this in a different way from estimateparams since we will change the maxdepth
	# thus we build a vector of depth that can be used to create a mask for gnhistories and traces
	# note: we also differ in taking the depth from :rcd is the trace which is the "true" recursion depth
	depths = map(trace->trace[:rcd], traces)
	
	# we also build up the depthsamplers in a different way: we assume that the best guess for the current recursion level
	# is the one from one below (and we start with the current sampler at depth 1, which must always exist)
	# this additionally allows for "gaps" in the recursion depths (which normally there shouldn't be, but might be possible
	# because of 'filtering' of the traces by parent samplers?)
	currentsampler = s.depthsamplers[1] # store existing sampler at depth 1
	s.depthsamplers = Vector{Sampler}() # clear out existing depth samplers
	maxdepth = isempty(depths) ? 1 : maximum(depths)
	for d in 1:maxdepth
		depthmask = convert(Vector{Bool},map(depth->depth==d, depths))
		depthtraces = map(trace->trace[:sub], traces[depthmask])
		if supportsconditionalmodelestimation(currentsampler)
			estimateconditionalmodel(currentsampler, cplabels, gnhistories[depthmask], depthtraces)
		else
			estimateparams(currentsampler, depthtraces)
		end
		push!(s.depthsamplers, deepcopy(currentsampler))
	end
	
end

function amendtrace(s::RecursionDepthSampler, trace, x)
	depth = trace[:dep]
	amendtrace(s.depthsamplers[depth], trace[:sub], x)
end

function ppsampler(s::RecursionDepthSampler, cpnames, indentdepth::Int=1)
	indent, colour = getindentandcolor(indentdepth)
	print_with_color(colour, getsamplertypename(s))
	for (depth, depthsampler) in enumerate(s.depthsamplers)
		println()		
		print_with_color(colour, indent * "$(depth): ") 
		ppsampler(depthsampler, cpnames, indentdepth+1)
	end
end

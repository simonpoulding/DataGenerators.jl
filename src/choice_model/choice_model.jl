#
# fallback choice model functions for parameter handling
#

paramranges(cm::ChoiceModel) = Tuple{Float64,Float64}[]

numparams(cm::ChoiceModel) = length(paramranges(cm::ChoiceModel))

setparams(cm::ChoiceModel, params) = nothing

getparams(cm::ChoiceModel) = (Float64)[]

estimateparams(cm::ChoiceModel, cptraces) = nothing

#
# utility function of use to all choice models
#

# extract dict of trace info indexed by cpid from a vector of cm traces
function extracttracesbycpid(cm::ChoiceModel, cmtraces)
	tracesbycpid = Dict{UInt,Vector{Dict}}()
	for cmtrace in cmtraces
		for (cpid, trace) in cmtrace
			if !haskey(tracesbycpid, cpid)
				tracesbycpid[cpid] = Dict[]
			end
			push!(tracesbycpid[cpid],trace)
		end
	end
	tracesbycpid
end

include("default_choice_model.jl")
include("sampler_choice_model.jl")
include("nmcs_choice_model.jl")
include("mcts_choice_model.jl")

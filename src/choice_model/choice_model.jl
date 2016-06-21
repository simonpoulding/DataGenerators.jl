#
# fallback choice model functions for parameter handling
#

# paramranges(cm::ChoiceModel) = Tuple{Float64,Float64}[]

numparams(cm::ChoiceModel) = length(paramranges(cm::ChoiceModel))

# reset any internal state of the choice model
resetstate!(cm::ChoiceModel) = nothing


# setparams(cm::ChoiceModel, params) = nothing

# getparams(cm::ChoiceModel) = (Float64)[]

# estimateparams(cm::ChoiceModel, cptraces) = nothing

include("default_choice_model.jl")
include("sampler_choice_model.jl")
include("nmcs_choice_model.jl")
include("mcts_choice_model.jl")

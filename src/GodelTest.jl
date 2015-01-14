module GodelTest

# exported functions that are used to generate objects from a generator
export generate, gen, many, meta, choicepointinfo, robustgen, GenerationTerminatedException

# exported functions that are used to register and match generators
export register, generatorfor

# exported Choice Models
export DefaultChoiceModel, SamplerChoiceModel, NMCSChoiceModel

# exported Choice Model functions
export paramranges, setparams, getparams

# generation and associated functions
include(joinpath("generation","generation.jl"))

# @generator macro
include(joinpath("generator_macro","generator_macro.jl"))
include(joinpath("generator_macro","generator_macro_choose_string.jl"))

# updating and querying registry metadata
include(joinpath("registry","registry.jl"))

# choice models
include(joinpath("choice_model","default_choice_model.jl"))
include(joinpath("choice_model","sampler_choice_model.jl"))
include(joinpath("choice_model","nmcs_choice_model.jl"))
include(joinpath("choice_model","limiter_choice_model.jl"))

end

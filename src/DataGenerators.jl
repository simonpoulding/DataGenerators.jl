module DataGenerators

#generator macro
export @generator

# exported functions that are used to generate objects from a generator
export choose, robustchoose, generate, gen, many, meta, choicepointinfo, robustgen, GenerationTerminatedException

# exported functions that are used to register and match generators
export register, generatorfor

# exported Choice Models
export DefaultChoiceModel, SamplerChoiceModel, NMCSChoiceModel, MCTSChoiceModel

# exported Choice Model functions
export paramranges, setparams, getparams, numparams, estimateparams, estimateconditionalmodel

# exported Translators
export xsd_generator, bnf_generator, regex_generator



using Distributions

const THIS_MODULE = current_module() # used when creating calls to this module in the macro

# translators
include(joinpath("translators","translators.jl"))

# generation and associated functions
include(joinpath("generation","generation.jl"))

# @generator macro
include(joinpath("generator","generator.jl"))

# updating and querying registry metadata
include(joinpath("registry","registry.jl"))

# choice models
include(joinpath("choice_model","choice_model.jl"))


end

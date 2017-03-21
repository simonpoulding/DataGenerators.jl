module DataGenerators

#generator macro
export @generator

# exported functions that are used to generate objects from a generator
export choose, robustchoose, generate, meta, choicepointinfo, choicemodel, setchoicemodel!, GenerationTerminatedException

# exported functions that are used to register and match generators
export register, generatorfor

# exported choice models application function
export setsimplechoicemodel!, setsamplerchoicemodel!, setnmcschoicemodel!, mctschoicemodel!

# exported Choice Model functions
export paramranges, setparams!, getparams, numparams, estimateparams!, estimateconditionalmodel!

using DataGeneratorTranslators
using Distributions
import Base.show


const THIS_MODULE = current_module() # used when creating calls to this module in the macro

# list of number types that are supported directly by generator macro
# (could do this automatically as leaf subtypes of Integer and AbstractFloat, but some of these we can't really handle directly yet
# - e.g. BigInt, BigFloat - and it is possible that custom subtypes could have been added)
const GENERATOR_SUPPORTED_CHOOSE_NUMBER_TYPES = Type[Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float16, Float32, Float64,]

# list of number types that are supported directly by generator macro
# (could do this automatically as leaf subtypes of AbstractString, but some of these we can't really handle directly yet)
const GENERATOR_SUPPORTED_CHOOSE_STRING_TYPES = Type[String,]

# all choose types supported directly by the generator maco
const GENERATOR_SUPPORTED_CHOOSE_TYPES = Type[GENERATOR_SUPPORTED_CHOOSE_NUMBER_TYPES; GENERATOR_SUPPORTED_CHOOSE_STRING_TYPES]


# generation and associated functions
include("generation.jl")

# @generator macro
include("generator_macro.jl")

# updating and querying registry metadata
include("registry.jl")

# choice models
include(joinpath("choice_model","choice_model.jl"))

end

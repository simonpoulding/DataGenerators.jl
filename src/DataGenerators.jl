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
export xsd_generator, bnf_generator, regex_generator, type_generator


using Distributions


const THIS_MODULE = current_module() # used when creating calls to this module in the macro

# list of number types that are supported directly by generator macro
# (could do this automatically as leaf subtypes of Integer and AbstractFloat, but some of these we can't really handle directly yet - e.g. BigInt, BigFloat - and it is possible that
# custom subtypes could have been added)
const GENERATOR_SUPPORTED_CHOOSE_NUMBER_TYPES = [Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64, Float16, Float32, Float64,]

# list of number types that are supported directly by generator macro
# (could do this automatically as leaf subtypes of AbstractString, but some of these we can't really handle directly yet)
const GENERATOR_SUPPORTED_CHOOSE_STRING_TYPES = [ASCIIString, UTF8String, UTF16String, UTF32String,]

# all choose types supported directly by the generator maco
const GENERATOR_SUPPORTED_CHOOSE_TYPES = [GENERATOR_SUPPORTED_CHOOSE_NUMBER_TYPES; GENERATOR_SUPPORTED_CHOOSE_STRING_TYPES]

# simple leaf types supported by Type translator as subtypes of abstract types
const TYPE_TRANSLATOR_SUPPORTED_SIMPLE_LEAF_TYPES = [GENERATOR_SUPPORTED_CHOOSE_TYPES; Symbol]


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

using DataGenerators.Translators

translate_from_xsd("mathml2.xsd","math", "MathMLGen","mathmlgen.jl")

include("mathmlgen.jl")

choose(MathMLGen)
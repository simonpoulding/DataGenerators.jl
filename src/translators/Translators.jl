module Translators

export translate_from_xsd, translate_from_bnf

include("parse.jl")
include("transform.jl")
include("build.jl")

include(joinpath("bnf","bnf.jl"))
include(joinpath("xsd","xsd.jl"))

end
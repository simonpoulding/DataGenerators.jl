include("parse.jl")
include("transform.jl")
include("build.jl")

include(joinpath("regex", "regex.jl"))
include(joinpath("type", "type.jl"))
include(joinpath("bnf", "bnf.jl"))
include(joinpath("xsd", "xsd.jl"))

function include_generator(genname::Symbol, translatefn::Function, translateargs...)
	genbuf = IOBuffer()
	translatefn(genbuf, genname, translateargs...)
	genstr = takebuf_string(genbuf)
	include_string(genstr)
	current_module().eval(genname)
end

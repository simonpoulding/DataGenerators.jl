include("bnf_parse.jl")
include("bnf_transform.jl")
include("bnf_build.jl")


function bnf_rules(bnf::IO, startvariable::AbstractString, syntax::Symbol=:ebnf, addwhitespace::Bool=true, rulenameprefix="")
	ast = parse_bnf(bnf::IO, syntax)
	transform_bnf_ast(ast, startvariable)
	transform_ast(ast)
	build_bnf_rules(ast, addwhitespace, rulenameprefix)
end

function bnf_generator(io::IO, genname::Symbol, bnf::IO, startvariable::AbstractString, syntax::Symbol=:ebnf, addwhitespace::Bool=true)
	rules = bnf_rules(bnf, startvariable, syntax, addwhitespace)
	description = "string accepted by BNF starting with variable " * escape_string(startvariable)
	output_generator(io, genname, description, rules)
end

bnf_generator(genname::Symbol, bnf::IO, startvariable::AbstractString, syntax::Symbol=:ebnf, addwhitespace::Bool=true) = include_generator(genname, bnf_generator, bnf, startvariable, syntax, addwhitespace)
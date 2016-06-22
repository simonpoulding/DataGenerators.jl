include("bnf_parse.jl")
include("bnf_transform.jl")
include("bnf_build.jl")

function translate_from_bnf(bnffilepath, startvariable, genname, genfilename, addwhitespace=true, syntax=:ebnf)

	ast = parse_bnf(bnffilepath, syntax)
	transform_bnf_ast(ast, startvariable)
	transform_ast(ast)

	genfile = open(genfilename,"w")
	build_bnf_generator(genfile, ast, genname, startvariable, addwhitespace)
	close(genfile)
	
end

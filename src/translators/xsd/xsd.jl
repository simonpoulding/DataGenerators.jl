include("xsd_parse.jl")
include("xsd_transform.jl")
include("xsd_build.jl")

function translate_from_xsd(xsduri, startelement, genname, genfilename, )

	ast = parse_xsd(xsduri)
	transform_xsd_ast(ast, startelement)
	transform_ast(ast)

	genfile = open(genfilename,"w")
	build_xsd_generator(genfile, ast, genname, startelement)
	close(genfile)

end


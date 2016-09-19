include("xsd_parse.jl")
include("xsd_transform.jl")
include("xsd_build.jl")


function xsd_rules(xsduri::AbstractString, startelement::AbstractString, rulenameprefix="")
	ast = parse_xsd(xsduri)
	transform_xsd_ast(ast, startelement)
	transform_ast(ast)
	build_xsd_rules(ast, rulenameprefix)
end

function xsd_generator(io::IO, genname::Symbol, xsduri::AbstractString, startelement::AbstractString)
	rules = xsd_rules(xsduri, startelement)
	description = "XML with root element " * escape_string(startelement)
	output_generator(io, genname, description, rules)
end

xsd_generator(genname::Symbol, xsduri::AbstractString, startelement::AbstractString) = include_generator(genname, xsd_generator, xsduri, startelement)

include("regex_parse.jl")
include("regex_transform.jl")
include("regex_build.jl")

function regex_rules(regex::AbstractString, datatype::DataType, rulenameprefix="")

	ast = parse_regex(regex, datatype)

	transform_regex_ast(ast)
	transform_ast(ast) # this standard transform (which analysis reachability) isn't really needed for a regex, but included for consistency with other translators

	build_regex_rules(ast, rulenameprefix)

end
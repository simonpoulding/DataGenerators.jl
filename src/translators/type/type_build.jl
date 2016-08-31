function build_type_rules(ast::ASTNode, rulenameprefix="")
	assign_rulenames(ast, rulenameprefix)
    rules = Vector{RuleSource}()
    build_type_rule(ast, rules)
    rules
end

function build_type_rule(node::ASTNode, rules::Vector{RuleSource})
    if node.func in [:type]
        build_type_type(node, rules)
    elseif node.func in [:datatype]
        build_type_datatype(node, rules)
    elseif node.func in [:union]
       	build_type_union(node, rules)
    elseif node.func in [:typevar, :abstractdatatype]
       	build_type_abstract_type(node, rules)
    elseif node.func in [:typevarndims]
    	build_type_typevarndims(node, rules)
    elseif node.func in [:typevarref] 
    	# do nothing (this should be handled by parent node)
    elseif node.func in [:value]
    	# do nothing (this should be handled by parent node)
    else
	   error("Unexpected type node with function $(node.func)")
    end
    for child in node.children
        build_type_rule(child, rules)
    end
end

# "start" rule doesn't need to do anything apart from to call the outmost type(could transform away?)
function build_type_type(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
    calledrulename = build_called_rulename(node.refs[1])
    push!(rule.source, "$(calledrulename)")
    build_rule_shortform_end(rule, node)
    push!(rules, rule)
end

function build_type_datatype(node::ASTNode, rules::Vector{RuleSource})
	if node.args[:datatype] in GENERATOR_SUPPORTED_CHOOSE_TYPES
		build_type_supported_choose_datatype(node, rules)
	elseif node.args[:name].name == :Array
		build_type_array(node, rules)
	elseif node.args[:name].name == :Tuple
		build_type_tuple(node, rules)
	elseif node.args[:name].name == :Dict
		build_type_dict(node, rules)
	elseif node.args[:name].name == :Symbol
		build_type_symbol(node, rules)
	# Vararg (only inside tuples?)
	# Enum?
	# bittypes?
	# composite types (have fieldnames, but may have zero size if singleton); 
	# Type
	# other "built-in types" e.g. Rational, BigInt?
	# pointers
	# aliases
	# Val
	# Nullable
	else
		error("Don't know how to build a rule for datatype $(node.args[:datatype])")
	end
end

# for directly supported datatypes, add a rule using choose(Datatype)
function build_type_supported_choose_datatype(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
    push!(rule.source, "choose($(node.args[:datatype]))")
    build_rule_shortform_end(rule, node)
    push!(rules, rule)
end

# child 1 is the element type; child 2 is either an value or typevar ref
# TODO dims and ndims of zero, and ensuring correct type when this occurs
function build_type_array(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_start(node)
    if node.children[2].func == :value
    	# if child 2 is a value, use this constant to set number of dimensions
    	ndims = node.children[2].args[:value]
	    push!(rule.source, "  ndims = $(ndims)")
	else
		# if child 2 is a typevar ref, need to call it to get number of dimensions
		calledndimsrulename = build_called_rulename(node.children[2])
	    push!(rule.source, "  ndims = $(calledndimsrulename)()")
	end
	push!(rule.source, "  dims = [length(plus(:dummy)) for i in 1:ndims]") # create dimensions using plus as this give more meaningful range of integers (TODO: is mult better?)
	calledtyperulename = build_called_rulename(node.children[1])
	push!(rule.source, "  arr = [$(calledtyperulename)() for i in 1:reduce(*, 1, dims)]") # create 1-dim array
	# TODO comprehension appears to allow better type inference than map when size of array is 0, but suspect this won't always be the case: may need an explicit convert
	push!(rule.source, "  reshape(arr, dims...)") # and then reshape it 
    build_rule_end(rule, node)
	push!(rules, rule)
end

# build typevar returning a number of dimensions
function build_type_typevarndims(node::ASTNode, rules::Vector{RuleSource})
	if node.args[:numrefs] > 1
		error("Bound typevars returning a number of dimensions are not currently handled") # but are they even possible?
	end
    rule = build_rule_shortform_start(node)
    push!(rule.source, "length(plus(:dummy))") # we use length(mult) rather than choose(Int) as this produced a more meaningful range of integers (TODO mult?)
    build_rule_shortform_end(rule, node)
    push!(rules, rule)	
end

# children are the tuple types
function build_type_tuple(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
    childrulecalls = join(map(child->"$(build_called_rulename(child))()", node.children), ",")
	push!(rule.source, "($(childrulecalls))")
    build_rule_shortform_end(rule, node)
	push!(rules, rule)
end

# TODO ensure type is inferred correctly 
function build_type_dict(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
	keyrulename = build_called_rulename(node.children[1])
	valuerulename = build_called_rulename(node.children[2])
    push!(rule.source, "[$(keyrulename)()=>$(valuerulename)() for i in 1:length(plus(:dummy))]")  # TODO mult
    build_rule_shortform_end(rule, node)
	push!(rules, rule)
end

# TODO handle zero 
function build_type_union(node::ASTNode, rules::Vector{RuleSource})
	@assert !isempty(node.children)
	for child in node.children
	    rule = build_rule_shortform_start(node)
		calledtyperulename = build_called_rulename(child)
	    push!(rule.source, "$(calledtyperulename)()")
	    build_rule_shortform_end(rule, node)
		push!(rules, rule)
	end
end

# currently the same as union, but may change in the future
function build_type_abstract_type(node::ASTNode, rules::Vector{RuleSource})
	@assert !isempty(node.children)
	for child in node.children
	    rule = build_rule_shortform_start(node)
		calledtyperulename = build_called_rulename(child)
	    push!(rule.source, "$(calledtyperulename)()")
	    build_rule_shortform_end(rule, node)
		push!(rules, rule)
	end
end

# build symbol from a string
function build_type_symbol(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_shortform_start(node)
	push!(rule.source, "symbol(choose(UTF8String))")
    build_rule_shortform_end(rule, node)
	push!(rules, rule)
end

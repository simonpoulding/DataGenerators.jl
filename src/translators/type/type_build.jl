function build_type_rules(ast::ASTNode, rulenameprefix="")
	assign_rulenames(ast, rulenameprefix)
    rules = Vector{RuleSource}()
    build_type_rule(ast, rules)
    rules
end

function build_type_rule(node::ASTNode, rules::Vector{RuleSource})
    if node.func in [:type]
        build_type_start(node, rules)
    elseif node.func in [:typeroot]
    	build_type_type_root(node, rules)
    elseif node.func in [:union]
    	build_type_union(node, rules)
    elseif node.func in [:typevar]
    	build_type_typevar(node, rules)
    elseif node.func in [:dt]
        build_type_datatype(node, rules)
    elseif node.func in [:cm]
        build_type_constructor_method(node, rules)
    elseif node.func in [:choose]
        build_type_choose_child(node, rules)
    elseif node.func in [:dtref, :cmref, :typerootref, :typevarref, :datatyperootref, :unionref]
    	# do nothing: referencing mechanism in build_called_rulename takes care of this
    else
	   error("Unexpected type node with function $(node.func)")
    end
    for child in node.children
        build_type_rule(child, rules)
    end
end

function build_type_start(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_start(node)
    push!(rule.source, "tvs = Dict{TypeVar, Type}()")  # NOTE: TypeVar are like symbols in that indentical TypeVars (name, bound, ub, lb)? are the same object: this may be an issue when handling constructor
    typestr = type_as_parseable_string(node.args[:type])
    typerootrulename = build_called_rulename(node.refs[1])
    push!(rule.source, "$(typerootrulename)(tvs, $(typestr))")
    build_rule_end(rule, node)
    push!(rules, rule)
end


function build_type_type_root(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvs","t"]

    datatyperootrulename = build_called_child_rulename(node, :dt)
    unionrulename = build_called_child_rulename(node, :union)

    push!(rule.source, "@assert !(isa(t, TypeVar) && (t.lb != Union{}))") # logic for handling typevar currently assumes lowerbound is not set: check here at the root
	push!(rule.source, "if isa(t, Union)")
    push!(rule.source, "  $(unionrulename)(tvs, t)")
    push!(rule.source, "else")
    push!(rule.source, "  if isa(t, TypeVar) && choose(Bool)")  # this may be important still for things like Vector{Union{}}, but when at top level, it makes no difference if we are then going to select one part of this union when it is processed
    push!(rule.source, "  	$(unionrulename)(tvs, t)")
	push!(rule.source, "  else")
    push!(rule.source, "  	$(datatyperootrulename)(tvs, t)")  # TODO expand for multiple data types
	push!(rule.source, "  end")
    push!(rule.source, "end")

    build_rule_end(rule, node)
    push!(rules, rule)
end


function build_type_union(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvs","t"]
    push!(rule.comments, "Union")

    typerootrulename = build_called_child_rulename(node, :typerootref)
    typevarrulename = build_called_child_rulename(node, :typevarref)

    # Note: this rule is distinct from that handling the datatype Union (see comments below for that datatype), since Union{S,T} (where S,T are types or typevars)
    # is an INSTANCE of Union, not a subtype
    # Instead this handles the fact:
    #  (a) Union{U<:T,V<:T} <: T, and thus we optionally expand request for a type <: T to Union{U<:T,V<:T}
    #  (b) when choosing an instance of Union{U,V} where choose randomly U or V, and pick an instance from therein
	push!(rule.source, "if isa(t, TypeVar)")
	push!(rule.source, "    Union{$(typerootrulename)(tvs, TypeVar(gensym(), t.ub)), $(typerootrulename)(tvs, TypeVar(gensym(), t.ub))}")
	# note: more than 2 types in the Union can occur through the recursive call to the typeroot rule: Union{A, Union{B,C}} is Union{A, B, C}
    push!(rule.source, "else")
	push!(rule.source, "  isempty(t.types) && error(\"cannot choose from an empty union\")")
    push!(rule.source, "  u = t.types[choose(Int, 1, length(t.types))]")
    push!(rule.source, "  if isa(u, TypeVar)")
    push!(rule.source, "    u = $(typevarrulename)(tvs, u)") # avoid an "exposed" single typevar as this will return a datatype not a value
    push!(rule.source, "  end")
    push!(rule.source, "  $(typerootrulename)(tvs, u)")
    push!(rule.source, "end")

    build_rule_end(rule, node)
    push!(rules, rule)
end


function build_type_typevar(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvs","t"]
    push!(rule.comments, "TypeVar")

	thisrulename = build_called_rulename(node)
    typerootrulename = build_called_child_rulename(node, :typerootref)

	push!(rule.source, "if isa(t, DataType)")
	push!(rule.source, "  if !isempty(t.parameters)") # avoid recreating type if it is not necessary - in particular, should not recreate datatype Union (<: Type) as Union{} - they are different things!
	push!(rule.source, "    newparameters = map(p -> $(thisrulename)(tvs, p), t.parameters)")
	push!(rule.source, "    primarytype = t.name.primary")
	push!(rule.source, "    primarytype{newparameters...}")
	push!(rule.source, "  else")
	push!(rule.source, "     t")
	push!(rule.source, "  end")
	push!(rule.source, "elseif isa(t, Union)")
	push!(rule.source, "  if !isempty(t.types)")
	push!(rule.source, "    newparameters = map(p -> $(thisrulename)(tvs, p), t.types)")
	push!(rule.source, "    Union{newparameters...}")
	push!(rule.source, "  else")
	push!(rule.source, "     t")
	push!(rule.source, "  end")
	push!(rule.source, "elseif isa(t, TypeVar)")  
	# TODO also need to handle TypeVar in upper/lower bound of typevar?
	# TODO handle ndims and other special case
	push!(rule.source, "  if t.bound")
	push!(rule.source, "    if haskey(tvs, t)")
	push!(rule.source, "      tvs[t]")
	push!(rule.source, "    else")
    push!(rule.source, "      tvs[t] = $(typerootrulename)(tvs, t)")
    push!(rule.source, "    end")
	push!(rule.source, "  else")
	push!(rule.source, "    $(typerootrulename)(tvs, t)")
	push!(rule.source, "  end")
	push!(rule.source, "else")
	push!(rule.source, "  t")
	push!(rule.source, "end")

    build_rule_end(rule, node)
    push!(rules, rule)
end


# TODO handle special cases:
# - symbol?
# - DataType
# - Function
function build_type_datatype(node::ASTNode, rules::Vector{RuleSource})

    rule = build_rule_start(node)
    rule.args = ["tvs","t"]
    dt = node.args[:datatype]
    typestr = type_as_parseable_string(node.args[:datatype])
    push!(rule.comments, typestr)

    typevarrulename = build_called_child_rulename(node, :typevarref)

    push!(rule.source, "const primarytype = $(typestr)")

    push!(rule.source, "ti = typeintersect(primarytype, isa(t, TypeVar) ? t.ub : t)")

	if node.args[:abstract]

		# abstract datatype

	    push!(rule.source, "isa(ti, DataType) || error(\"type \$(t) cannot be handled by rule for $(typestr)\")") # captures case when no intersection, i.e. Union{}
	    push!(rule.source, "if ti.name == primarytype.name") # if intersect is this type (or a parameterised version thereof), assume any subtype could apply (this is not necessarily true)
		choosesubtypechildren = filter(child -> child.func == :choose, node.children)
		@assert length(choosesubtypechildren) <= 1
	   	if !isempty(choosesubtypechildren)
			choosesubtyperulename = build_called_rulename(choosesubtypechildren[1])
		    push!(rule.source, "  if isa(t, TypeVar) && choose(Bool)")
		    push!(rule.source, "    $(typevarrulename)(tvs, ti)") # expand any typevars and return this abstract type
		    push!(rule.source, "  else")

		    if dt == Type # special case since when T in Type{T} is specified, no subtypes apply, so it is acts like a concrete type
		    	push!(rule.source, "    if isa(t, TypeVar) || isa(ti.parameters[1], TypeVar)")
			    push!(rule.source, "      $(choosesubtyperulename)(tvs, t)")
		    	push!(rule.source, "    else")
		    	push!(rule.source, "      ti.parameters[1]")
		    	push!(rule.source, "    end")
		    else
			    push!(rule.source, "    $(choosesubtyperulename)(tvs, t)")
		   	end

		    push!(rule.source, "  end")
		    push!(rule.source, "else")
		    for child in node.children
		    	if child.func == :dt
					subtypestr = type_as_parseable_string(child.args[:datatype])
					subtyperulename = build_called_rulename(child)
		        	push!(rule.source, "  (t <: $(subtypestr)) ? $(subtyperulename)(tvs, t) :")
		        end
		    end
		    push!(rule.source, "  error(\"no applicable subtype rule for type \$(t) in rule for $(typestr)\")")
		else
			push!(rule.source, "  error(\"no supported subtypes in rule for $(typestr)\")")
		end
		push!(rule.source, "end")

	else

		# concrete datatype

	    push!(rule.source, "(isa(ti, DataType) && (ti.name == primarytype.name)) || error(\"type \$(t) cannot be handled by rule for $(typestr)\")") # captures case when no intersection, i.e. Union{}, or type is not this concrete type
	    push!(rule.source, "ti = $(typevarrulename)(tvs, ti)") # expand any typevars
	    
	    push!(rule.source, "if isa(t, TypeVar)")
	    push!(rule.source, "  ti")
	    push!(rule.source, "else")

	    if dt in GENERATOR_SUPPORTED_CHOOSE_TYPES

	    	push!(rule.source, "  choose($(typestr))::ti")  # NB type assert

	    elseif dt == Tuple

		    typerootrulename = build_called_child_rulename(node, :typerootref)
	    	push!(rule.source, "  tuple(map(p->$(typerootrulename)(tvs, p), ti.parameters)...)::ti")  # NB type assert

	    elseif dt == DataType

		    datatyperootrulename = build_called_child_rulename(node, :datatyperootref)
	    	# return a DataType using the TypeVar mechanism
	    	# note: Union{S,T} is not a DataType, and therefore we access the datatyperoot directly to avoid possibility of this
	    	push!(rule.source, "  $(datatyperootrulename)(tvs, TypeVar(gensym(), Any))::ti")  # NB type assert

	    elseif dt == Union

	    	# note: 
	    	#  a) Union{S,T} is not a subtype of Union (and nor, therefore, Type)
	    	#  b) instead, Union{S,T} is an instance of Union
	    	#  c) Union{} is an instance of Union
	    	# thus cannot reach here with a parameterised Union (as this would be an instance, not a Type)
	    	# so return an instance of Union, i.e. a Union of 0 or more datatypes
		    datatyperootrulename = build_called_child_rulename(node, :datatyperootref)
	    	# return a union of 0 or more DataTypes using the TypeVar mechanism
			push!(rule.source, "  Union{mult($(datatyperootrulename)(tvs, TypeVar(gensym(), Any)))...}::ti") # NB type assert
			# Note: there is a chance that Union is simplified to just one of its consituent datatypes, in which case the type assert ::Union
			# will fail 
	    	
	    else

		    chooseconstructorchildren = filter(child -> child.func == :choose, node.children)
			@assert length(chooseconstructorchildren) <= 1
		   	if !isempty(chooseconstructorchildren)
				chooseconstructorrulename = build_called_rulename(chooseconstructorchildren[1])
			    push!(rule.source, "  $(chooseconstructorrulename)(tvs, ti)::ti")  # NB type assert
		   	else
	    		push!(rule.source, "  error(\"no constructor method in rule for $(typestr)\")")
	    	end

	    end

		push!(rule.source, "end")

	end

    build_rule_end(rule, node)
    push!(rules, rule)

end

function build_type_constructor_method(node::ASTNode, rules::Vector{RuleSource})
	
	rule = build_rule_start(node)
    rule.args = ["tvs","t"]
    cm = node.args[:method]
    push!(rule.comments, "$(cm)")
    

    push!(rule.source, "error(\"would have called: $(cm)\")")
    
    build_rule_end(rule, node)
    push!(rules, rule)

end

function build_type_choose_child(node::ASTNode, rules::Vector{RuleSource})
	@assert !isempty(node.children)
	for child in filter(child -> child.func in [:dtref; :cmref;], node.children)
	    rule = build_rule_shortform_start(node)
	    rule.args = ["tvs","t"]
		childrulename = build_called_rulename(child)
	    push!(rule.source, "$(childrulename)(tvs, t)")
	    build_rule_shortform_end(rule, node)
		push!(rules, rule)
	end
end


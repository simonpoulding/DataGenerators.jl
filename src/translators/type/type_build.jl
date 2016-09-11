function build_type_rules(ast::ASTNode, rulenameprefix="")
	assign_rulenames(ast, rulenameprefix)
    rules = Vector{RuleSource}()
    build_type_rule(ast, rules)
    rules
end

function build_type_rule(node::ASTNode, rules::Vector{RuleSource})
    if node.func in [:start]
        build_type_start(node, rules)
    elseif node.func in [:instance]
    	build_type_instance(node, rules)
    elseif node.func in [:datatype]
    	build_type_datatype(node, rules)
    elseif node.func in [:type]
    	build_type_type(node, rules)
    elseif node.func in [:dt]
        build_type_dt(node, rules)
    elseif node.func in [:cm]
        build_type_cm(node, rules)
    elseif node.func in [:choose]
        build_type_choose(node, rules)
    elseif node.func in [:dtref; :cmref; :instanceref; :datatyperef; :typeref;]
    	# do nothing: referencing mechanism in build_called_rulename takes care of this
    else
	   error("unexpected type node with function $(node.func)")
    end
    for child in node.children
        build_type_rule(child, rules)
    end
end

# start
function build_type_start(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_start(node)

    push!(rule.source, "  tvs = Dict{TypeVar, Type}()") 
    typstr = type_as_parseable_string(node.args[:type])
    calledrulename = build_called_rulename(node.refs[1]) # instance rule
    push!(rule.source, "  $(calledrulename)(tvs, $(typstr))")
    
    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns an instance of the passed Type or TypeVar
function build_type_instance(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvs"; "totv"]

    dtrootrulename = build_called_child_rulename(node, :dtref)
    datatyperulename = build_called_child_rulename(node, :datatyperef)

    push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  dt = $(datatyperulename)(tvs, totv)::DataType")
    push!(rule.source, "  $(dtrootrulename)(tvs, dt)")

    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns a DataType for the passed Type or TypeVar
function build_type_datatype(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvs"; "totv"]

    thisrulename = build_called_rulename(node)
    typerulename = build_called_child_rulename(node, :typeref)

    push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  t = $(typerulename)(tvs, totv)::Type")
    push!(rule.source, "  begin")
    push!(rule.source, "    if isa(t, Union)")
    push!(rule.source, "      isempty(t.types) && error(\"Cannot select an instance from Union{}\")")
   	push!(rule.source, "      $(thisrulename)(tvs, t.types[choose(Int, 1, length(t.types))])")
   	push!(rule.source, "    else")
    # TODO - handle TypeConstructors here?
    push!(rule.source, "      t")
    push!(rule.source, "    end")
    push!(rule.source, "  end::DataType")

    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns a Type for the passed Type or TypeVar
function build_type_type(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvs"; "totv"]

    dtrootrulename = build_called_child_rulename(node, :dtref)
    datatyperulename = build_called_child_rulename(node, :datatyperef)

    push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  begin")
	push!(rule.source, "    if isa(totv, TypeVar)")
    push!(rule.source, "      if totv.bound && haskey(tvs, totv)")
	push!(rule.source, "        tvs[totv]")
	push!(rule.source, "      else")
	push!(rule.source, "        t = begin")
	push!(rule.source, "          if choose(Bool)")
	push!(rule.source, "            @assert totv.lb == Union{}")
	push!(rule.source, "            dt = $(datatyperulename)(tvs, totv.ub)::DataType") # in case it is a union, convert TypeVar's ub to a datatype
	push!(rule.source, "            $(dtrootrulename)(tvs, TypeVar(gensym(), dt))") # use a new TypeVar with a guaranteed datatype ub (no need to bind as this is only used to select a valid subtype at random)
	push!(rule.source, "          else")
	push!(rule.source, "            Union{TypeVar(gensym(), totv.lb, totv.ub, totv.bound), TypeVar(gensym(), totv.lb, totv.ub, totv.bound)}")
	push!(rule.source, "          end")
	push!(rule.source, "        end::Type")
	push!(rule.source, "        if totv.bound")
	push!(rule.source, "           tvs[totv] = t")
    push!(rule.source, "        end")
    push!(rule.source, "        t")
    push!(rule.source, "      end")
    push!(rule.source, "    else")
    push!(rule.source, "      totv")
    push!(rule.source, "    end")
    push!(rule.source, "  end::Type")

    build_rule_end(rule, node)
    push!(rules, rule)
end


function build_type_parameterised_datatype(ruleprimarydt::DataType)
    if any(p->p.name == Vararg.name, ruleprimarydt.parameters) # TODO handle Varargs more elegantly than this
    	"((ruleprimarydt.name == dt.name) ? dt : ruleprimarydt)::DataType"
    else
    	"typeintersect(ruleprimarydt, dt)::DataType"
    end
end

function build_type_dt(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_start(node)
    rule.args = ["tvs"; "dtotv"]

    ruleprimarydt = node.args[:datatype]
    ruleprimarydtstr = type_as_parseable_string(ruleprimarydt)
    push!(rule.comments, ruleprimarydtstr)

    push!(rule.source, "  @assert isa(dtotv, Union{DataType, TypeVar})")

    push!(rule.source, "  const ruleprimarydt = $(ruleprimarydtstr)::DataType")
    push!(rule.source, "  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType")
    # note: many of the type operations used below (e.g. subtyping) could work just as well with the TypeVar itself,
    # but not all, so to make it easy, extract the relevant datatype

	if node.args[:abstract]

		# abstract datatype

	    push!(rule.source, "  if ruleprimarydt <: dt.name.primary") 
		# case (1) - type of this rule or *any* subtype could be valid (although this may not necessarily be true for some parameterisations)

	    push!(rule.source, "    if isa(dtotv, TypeVar) && choose(Bool)")
		push!(rule.source, "      " * build_type_parameterised_datatype(ruleprimarydt))
	    push!(rule.source, "    else")

	    if ruleprimarydt == Type
	    	# special case: for Type (and its subtypes), we apply the type rule to singleparameter to return a Type
	    	typerulename = build_called_child_rulename(node, :typeref)
			push!(rule.source, "      $(typerulename)(tvs, dt.parameters[1])")
	    else
			chooserulename = build_called_child_rulename(node, :choose)
			push!(rule.source, "      $(chooserulename)(tvs, dtotv)")
		end
	    push!(rule.source, "    end")

	    push!(rule.source, "  else")    
	    # case (2) - the required type is one of the subtypes of this rule, so find and call that rule

	    for child in filter(child -> child.func == :dt, node.children)
			subtypestr = type_as_parseable_string(child.args[:datatype])
			subtyperulename = build_called_rulename(child)
        	push!(rule.source, "    (dt <: $(subtypestr)) ? $(subtyperulename)(tvs, dtotv) :")
        	# TODO, could 'hardcode' list of primary types from subtypes
        	# TODO: instead of dt, could use dt.name.primary
	    end
		push!(rule.source, "    error(\"no applicable subtype rule for type \$(dt) in rule for $(ruleprimarydtstr)\")")

		push!(rule.source, "  end")

	else

		# concrete datatype

	    push!(rule.source, "  if isa(dtotv, TypeVar)")
		push!(rule.source, "    " * build_type_parameterised_datatype(ruleprimarydt))
		push!(rule.source, "  else")

		chooserulename = build_called_child_rulename(node, :choose)
		push!(rule.source, "    parameteriseddt = " * build_type_parameterised_datatype(ruleprimarydt))
	    push!(rule.source, "    $(chooserulename)(tvs, parameteriseddt)::parameteriseddt")  # NB type assert

		push!(rule.source, "  end")

	end

    build_rule_end(rule, node)
    push!(rules, rule)

end

function build_type_cm(node::ASTNode, rules::Vector{RuleSource})
	
	rule = build_rule_start(node)
   	rule.args = ["tvs"; "dt"]

    push!(rule.source, "  @assert isa(dt, DataType)")

	if haskey(node.args, :method)

	    cm = node.args[:method]
	    push!(rule.comments, "constructor method $(cm)")
	    
	    push!(rule.source, "  error(\"would have called: $(cm)\")")
	    
	else

		dt = node.args[:datatype]
	    push!(rule.comments, "constructor method for datatype $(dt)")

		if dt in TRANSLATOR_CONSTRUCTED_TYPES

			if dt in GENERATOR_SUPPORTED_CHOOSE_TYPES

				typestr = type_as_parseable_string(node.args[:datatype])
		    	push!(rule.source, "  choose($(typestr))")

		    elseif dt == Tuple

			    instancerulename = build_called_child_rulename(node, :instanceref)
		    	push!(rule.source, "  els = Vector{Any}()")
		    	push!(rule.source, "  for p in dt.parameters")
		    	push!(rule.source, "    if isa(p, DataType) && (p.name == Vararg.name)")
		    	push!(rule.source, "       append!(els, mult($(instancerulename)(tvs, p.parameters[1])))")
		    	push!(rule.source, "    else")
		    	push!(rule.source, "       push!(els, $(instancerulename)(tvs, p))")
		    	push!(rule.source, "    end")
		    	push!(rule.source, "  end")
		    	push!(rule.source, "  tuple(els...)")

		    # elseif dt == DataType

			    # datatyperootrulename = build_called_child_rulename(node, :datatyperootref)
		    	# return a DataType using the TypeVar mechanism
		    	# note: Union{S,T} is not a DataType, and therefore we access the datatyperoot directly to avoid possibility of this
		    	# TODO: a type can also include TypeVars
		    	# push!(rule.source, "  $(datatyperootrulename)(tvs, TypeVar(gensym(), Any))::paramtyp")  # NB type assert

		    # elseif dt == Union

		    	# note: 
		    	#  a) Union{S,T} is not a subtype of Union (and nor, therefore, Type)
		    	#  b) instead, Union{S,T} is an instance of Union
		    	#  c) Union{} is an instance of Union
		    	# thus cannot reach here with a parameterised Union (as this would be an instance, not a Type)
		    	# so return an instance of Union, i.e. a Union of 0 or more datatypes
			    # datatyperootrulename = build_called_child_rulename(node, :datatyperootref)
		    	# return a union of 0 or more DataTypes using the TypeVar mechanism
				# push!(rule.source, "  Union{mult($(datatyperootrulename)(tvs, TypeVar(gensym(), Any)))...}::paramtyp") # NB type assert
				# Note: there is a chance that Union is simplified to a single consituent datatype, in which case the type assert ::Union
				# will fail 

				# SOLUTION to above issue: if Union resolves to a single DataType, just return Union{} (as this won't be constructed in TypeRoot rule)

				# Union (and indeed DataType beyond top level) should include TypeVars - for Union may need to construct isolated ones rather than 
				# simply unresolve datatype parameters

		    # elseif dt == TypeConstructor

		    else

		    	# TODO
		    	push!(rule.comments, "#TODO")
		    	push!(rule.source, "  error(\"need a constructor method for translator constructed type $(dt)\")")

		    end

		end # translator constructed types

	end  # method or datatype

    build_rule_end(rule, node)
    push!(rules, rule)

end

function build_type_choose(node::ASTNode, rules::Vector{RuleSource})
	@assert !isempty(node.children)
	for child in filter(child -> child.func in [:dtref; :cmref;], node.children)
	    rule = build_rule_shortform_start(node)
	    rule.args = ["tvs"; "p"]
		childrulename = build_called_rulename(child)
	    push!(rule.source, "$(childrulename)(tvs, p)")
	    build_rule_shortform_end(rule, node)
		push!(rules, rule)
	end
end


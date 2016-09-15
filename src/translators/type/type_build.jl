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
    elseif node.func in [:method]
    	build_type_method(node, rules)
    elseif node.func in [:dt]
        build_type_dt(node, rules)
    elseif node.func in [:cm]
        build_type_cm(node, rules)
    elseif node.func in [:choose]
        build_type_choose(node, rules)
    elseif node.func in [:dtref; :cmref; :instanceref; :datatyperef; :typeref; :methodref]
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

    push!(rule.source, "  tvlookup = Dict{TypeVar, Any}()") 
    typstr = type_as_parseable_string(node.args[:type])
    calledrulename = build_called_rulename(node.refs[1]) # instance rule
    push!(rule.source, "  $(calledrulename)(tvlookup, $(typstr))")
    
    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns an instance of the passed Type or TypeVar
function build_type_instance(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "totv"]

    dtrootrulename = build_called_child_rulename(node, :dtref)
    datatyperulename = build_called_child_rulename(node, :datatyperef)

    push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  dt = $(datatyperulename)(tvlookup, totv)::DataType")
    push!(rule.source, "  $(dtrootrulename)(tvlookup, dt)")

    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns a DataType for the passed Type or TypeVar
function build_type_datatype(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "totv"]

    thisrulename = build_called_rulename(node)
    typerulename = build_called_child_rulename(node, :typeref)

    push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  t = $(typerulename)(tvlookup, totv)::Type")
    push!(rule.source, "  begin")
    push!(rule.source, "    if isa(t, Union)")
    push!(rule.source, "      isempty(t.types) && error(\"Cannot select an instance from Union{}\")")
   	push!(rule.source, "      $(thisrulename)(tvlookup, t.types[choose(Int, 1, length(t.types))])")
   	push!(rule.source, "    else")
    # TODO - handle TypeConstructors here?
    push!(rule.source, "      t")
    push!(rule.source, "    end")
    push!(rule.source, "  end::DataType")

    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns a Type (or sometimes an instance value, e.g. when the TypeVar is for any array dimension or symbol) for the passed Type  or TypeVar
function build_type_type(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "totv"]

    dtrootrulename = build_called_child_rulename(node, :dtref)
    datatyperulename = build_called_child_rulename(node, :datatyperef)

    # push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  begin")
	push!(rule.source, "    if isa(totv, TypeVar)")
    push!(rule.source, "      if totv.bound && haskey(tvlookup, totv)")
	push!(rule.source, "        tvlookup[totv]")
	push!(rule.source, "      else")
	push!(rule.source, "        t = begin")
	# Hardcode some logic that is not available purely from the TypeVar itself: we assume a TypeVar named N refers to a number of dimensions (i.e. an integer >= 0)
	# rather than a datatype (as implied by the ub of the TypeVar)
	push!(rule.source, "          if totv.name == :N")
	push!(rule.source, "            length(plus(:dummy))::Int") #TODO: for the moment, force dimensions to use a geometric distribution; #TODO also could allow 0
	push!(rule.source, "          else")
	push!(rule.source, "            if choose(Bool)")
	push!(rule.source, "              @assert totv.lb == Union{}")
	push!(rule.source, "              dt = $(datatyperulename)(tvlookup, totv.ub)::DataType") # in case it is a union, convert TypeVar's ub to a datatype
	push!(rule.source, "              $(dtrootrulename)(tvlookup, TypeVar(gensym(totv.name), dt))::DataType") # use a new TypeVar with a guaranteed datatype ub (no need to bind as this is only used to select a valid subtype at random)
	push!(rule.source, "            else")
	push!(rule.source, "              Union{TypeVar(gensym(totv.name), totv.lb, totv.ub, totv.bound), TypeVar(gensym(totv.name), totv.lb, totv.ub, totv.bound)}")
	push!(rule.source, "            end")
	push!(rule.source, "          end")
	push!(rule.source, "        end")
	push!(rule.source, "        if totv.bound")
	push!(rule.source, "           tvlookup[totv] = t")
    push!(rule.source, "        end")
    push!(rule.source, "        t")
    push!(rule.source, "      end")
    push!(rule.source, "    else")
    push!(rule.source, "      totv")
    push!(rule.source, "    end")
    push!(rule.source, "  end")

    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns the result of calling a method with a instance of the given signature
function build_type_method(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "dt"; "fname"; "sig";]

    #   fname is function name (Symbol)
    #   sig is method signature (DataType) - specifically a Tuple
    push!(rule.source, "  @assert sig <: Tuple")
    push!(rule.source, "  @assert isa(dt, DataType)")

    push!(rule.source, "  argstype = deepcopy(sig)")

    # ensure required datatype is fully parameterised
    typerulename = build_called_child_rulename(node, :typeref)
    push!(rule.source, "   paramdt = dt.name.primary{map(p->$(typerulename)(tvlookup, p), dt.parameters)...}") # any bound typevars to be resolved will be in the old bound typevar context, so use that
	
    # create a new lookup context for bound typevars
    push!(rule.source, "  newtvlookup = Dict{TypeVar, Any}()") 

    push!(rule.source, "  if fname == :call")
    # if constructor method is a call, then we must match type to the first parameter of the signature tuple, and bind variables accordingly:
    push!(rule.source, "    @assert !isempty(argstype.parameters)")
    # note: first parameter of call may not have bound variables, so we force them to be as follows:
    push!(rule.source, "    boundtvs = DataGenerators.extract_bound_typevars(argstype)") # get all bind variable in the args Tuple
    push!(rule.source, "    firstargtype = deepcopy(argstype.parameters[1])")
    push!(rule.source, "    firstargtype = DataGenerators.bind_matching_unbound_typevars(firstargtype, boundtvs)") # bind these if they occur in the first parameter
    push!(rule.source, "    DataGenerators.match_template_bound_typevars(firstargtype, Type{paramdt}, newtvlookup)") # and match them to value in the desired datatype
    # note: argstype remains unchanged
	push!(rule.source, "  end")

	# # if any of the bound typevars are still typevars, resolve them now
	# push!(rule.source, "  for (tv, t) in newtvlookup")
 #    typerulename = build_called_child_rulename(node, :typeref)
 #    push!(rule.source, "    newtvlookup[tv] = $(typerulename)(tvlookup, t)") # any bound typevars to be resolved will be in the old bound typevar context, so use that
	# push!(rule.source, "  end")

    push!(rule.source, "  argstype = DataGenerators.resolve_bound_typevars(argstype, newtvlookup)")
    # TODO also resolve unbound typevars (perhaps only some)

	instancerulename = build_called_child_rulename(node, :instanceref)
	# push!(rule.source, "  args = $(instancerulename)(newtvlookup, argstype)::Tuple") # note: newtvlookup
	# TODO: adding this line makes first generation extremely long (but not subsequent) - why?
	push!(rule.source, "  instancefn = _stateparam.generator.rulemethodnames[symbol(\"$(instancerulename)\")]")
	push!(rule.source, "  instancecallexpr = Expr(:call, instancefn, _genparam, _stateparam, newtvlookup, argstype)")
	push!(rule.source, "  args = eval(instancecallexpr)")


	push!(rule.source, "  info(\"calling \$(fname) with signature \$(sig) with args \$(args) to get datatype \$(dt) (parameterised type of \$(paramdt))\")")
	push!(rule.source, "  f = eval(parse(\"\$(fname)\"))")
	push!(rule.source, "  invoke(f, sig, args...)::dt") # note: original sig
	# note dt, not paramdt, in type assert: we are okay if parameters are ignored (I think - unless they are bound??)

    build_rule_end(rule, node)
    push!(rules, rule)
end


function build_type_dt(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_start(node)
    rule.args = ["tvlookup"; "dtotv"]

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
		push!(rule.source, "      DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)")
	    push!(rule.source, "    else")

		chooserulename = build_called_child_rulename(node, :choose)
	    if ruleprimarydt == Type
	    	# special case: for Type we apply the type rule to the single parameter to return a Type
	    	typerulename = build_called_child_rulename(node, :typeref)
	    	push!(rule.source, "      if dt.name == Type.name")
			push!(rule.source, "        $(typerulename)(tvlookup, dt.parameters[1])")
			push!(rule.source, "      else")
			push!(rule.source, "        $(chooserulename)(tvlookup, dtotv)")
			push!(rule.source, "      end")
	    else
			push!(rule.source, "      $(chooserulename)(tvlookup, dtotv)")
		end
	    push!(rule.source, "    end")

	    push!(rule.source, "  else")    
	    # case (2) - the required type is one of the subtypes of this rule, so find and call that rule

	    for child in filter(child -> child.func == :dt, node.children)
			subtypestr = type_as_parseable_string(child.args[:datatype])
			subtyperulename = build_called_rulename(child)
        	push!(rule.source, "    (dt <: $(subtypestr)) ? $(subtyperulename)(tvlookup, dtotv) :")
        	# TODO, could 'hardcode' list of primary types from subtypes
        	# TODO: instead of dt, could use dt.name.primary
	    end
		push!(rule.source, "    error(\"no applicable subtype rule for type \$(dt) in rule for $(ruleprimarydtstr)\")")

		push!(rule.source, "  end")

	else

		# concrete datatype

	    push!(rule.source, "  if isa(dtotv, TypeVar)")
		push!(rule.source, "    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)")
		push!(rule.source, "  else")

		chooserulename = build_called_child_rulename(node, :choose)
		push!(rule.source, "    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)")
	    # push!(rule.source, "    $(chooserulename)(tvlookup, parameteriseddt)::parameteriseddt")  
	    push!(rule.source, "    $(chooserulename)(tvlookup, parameteriseddt)")  
	    # TODO type assert can't always work, so remove it for the moment.
	    # Example: when a Tuple{Type{T}, ....} is asserted: T (which *is* a Type{T}) is recognised as a DataType, not a Type{T}, and so assertion fails

		push!(rule.source, "  end")

	end

    build_rule_end(rule, node)
    push!(rules, rule)

end

function build_type_cm(node::ASTNode, rules::Vector{RuleSource})
	
	rule = build_rule_start(node)
   	rule.args = ["tvlookup"; "dt";]

    push!(rule.source, "  @assert isa(dt, DataType)")

	if haskey(node.args, :method)

	    cm = node.args[:method]
	    push!(rule.comments, "constructor method $(cm)")

		methodrulename = build_called_child_rulename(node, :methodref)
	    push!(rule.source, "  $(methodrulename)(tvlookup, dt, symbol(\"$(cm.func.code.name)\"), $(type_as_parseable_string(cm.sig)))")
	    
	else

		primarydt = node.args[:datatype]
	    push!(rule.comments, "constructor method for datatype $(primarydt)")

		if primarydt in TRANSLATOR_CONSTRUCTED_TYPES

			if primarydt in GENERATOR_SUPPORTED_CHOOSE_TYPES

				primarydtstr = type_as_parseable_string(primarydt)
		    	push!(rule.source, "  choose($(primarydtstr))")

		    elseif primarydt == Tuple

			    instancerulename = build_called_child_rulename(node, :instanceref)
		    	push!(rule.source, "  els = Vector{Any}()")
		    	push!(rule.source, "  for p in dt.parameters")
		    	push!(rule.source, "    if isa(p, DataType) && (p.name == Vararg.name)")
		    	push!(rule.source, "       append!(els, mult($(instancerulename)(tvlookup, p.parameters[1])))")
		    	push!(rule.source, "    else")
		    	push!(rule.source, "       push!(els, $(instancerulename)(tvlookup, p))")
		    	push!(rule.source, "    end")
		    	push!(rule.source, "  end")
		    	push!(rule.source, "  tuple(els...)")

		    # elseif dt == DataType

			    # datatyperootrulename = build_called_child_rulename(node, :datatyperootref)
		    	# return a DataType using the TypeVar mechanism
		    	# note: Union{S,T} is not a DataType, and therefore we access the datatyperoot directly to avoid possibility of this
		    	# TODO: a type can also include TypeVars
		    	# push!(rule.source, "  $(datatyperootrulename)(tvlookup, TypeVar(gensym(), Any))::paramtyp")  # NB type assert


		    # elseif dt == Union

		    	# note: 
		    	#  a) Union{S,T} is not a subtype of Union (and nor, therefore, Type)
		    	#  b) instead, Union{S,T} is an instance of Union
		    	#  c) Union{} is an instance of Union
		    	# thus cannot reach here with a parameterised Union (as this would be an instance, not a Type)
		    	# so return an instance of Union, i.e. a Union of 0 or more datatypes
			    # datatyperootrulename = build_called_child_rulename(node, :datatyperootref)
		    	# return a union of 0 or more DataTypes using the TypeVar mechanism
				# push!(rule.source, "  Union{mult($(datatyperootrulename)(tvlookup, TypeVar(gensym(), Any)))...}::paramtyp") # NB type assert
				# Note: there is a chance that Union is simplified to a single consituent datatype, in which case the type assert ::Union
				# will fail 

				# SOLUTION to above issue: if Union resolves to a single DataType, just return Union{} (as this won't be constructed in TypeRoot rule)

				# Union (and indeed DataType beyond top level) should include TypeVars - for Union may need to construct isolated ones rather than 
				# simply unresolve datatype parameters

		    # elseif dt == TypeConstructor

		    else

		    	# TODO
		    	push!(rule.source, "  error(\"need a constructor method for translator constructed type $(primarydt)\")")

		    end
		else

	    	push!(rule.comments, "#TODO")
	    	push!(rule.source, "  error(\"need a constructor method for type $(primarydt)\")")

		end # translator constructed types


	end  # method or datatype

    build_rule_end(rule, node)
    push!(rules, rule)

end

function build_type_choose(node::ASTNode, rules::Vector{RuleSource})
	@assert !isempty(node.children)
	for child in filter(child -> child.func in [:dtref; :cmref;], node.children)
	    rule = build_rule_shortform_start(node)
	    rule.args = ["tvlookup"; "p"]
		childrulename = build_called_rulename(child)
	    push!(rule.source, "$(childrulename)(tvlookup, p)")
	    build_rule_shortform_end(rule, node)
		push!(rules, rule)
	end
end


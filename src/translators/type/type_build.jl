function build_type_rules(ast::ASTNode, rulenameprefix="")
	assign_rulenames(ast, rulenameprefix)
    rules = Vector{RuleSource}()
    build_type_rule(ast, rules)
    rules
end

function build_type_rule(node::ASTNode, rules::Vector{RuleSource})
    if node.func in [:start]
        build_type_start(node, rules)
    elseif node.func in [:value]
    	build_type_value(node, rules)
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
    elseif node.func in [:dtref; :cmref; :valueref; :datatyperef; :typeref; :methodref;]
    	# do nothing: referencing mechanism in build_called_rulename takes care of this
    else
	   error("unexpected type node with function $(node.func)")
    end
    for child in node.children
        build_type_rule(child, rules)
    end
end

# work around to try and avoid long compilation times (which may be as a result of type inference):
# make all reference calls (which are the ones that could cause loops between rules) indirect using the eval mechanism
# on the assumption that the type inference algorithm will not follow these calls
function build_child_call_as_eval(node::ASTNode, func::Symbol, args::AbstractString)
	childrulename = build_called_child_rulename(node, func)
	"eval(Expr(:call, _stateparam.generator.rulemethodnames[symbol(\"$(childrulename)\")], _genparam, _stateparam, $(args)))"
end


# start
function build_type_start(node::ASTNode, rules::Vector{RuleSource})
    rule = build_rule_start(node)

    push!(rule.source, "  tvlookup = Dict{TypeVar, Any}()") 
    typstr = type_as_parseable_string(node.args[:type])
    calledrulename = build_called_rulename(node.refs[1]) # value rule
    push!(rule.source, "  $(calledrulename)(tvlookup, $(typstr))")
    
    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns an value of the passed Type or TypeVar
function build_type_value(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "totv"]

    push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")

    # datatyperulename = build_called_child_rulename(node, :datatyperef)
    # push!(rule.source, "  dt = $(datatyperulename)(tvlookup, totv)::DataType")
    # dtrootrulename = build_called_child_rulename(node, :dtref)
    # push!(rule.source, "  $(dtrootrulename)(tvlookup, dt)")
    push!(rule.source, "  dt = " * build_child_call_as_eval(node, :datatyperef, "tvlookup, totv") * "::DataType")
    push!(rule.source, "  " * build_child_call_as_eval(node, :dtref, "tvlookup, dt"))

    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns a DataType for the passed Type or TypeVar - the DataType may (randomly) be partially or fully parameterised
function build_type_datatype(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "totv"]

    thisrulename = build_called_rulename(node)
    typerulename = build_called_child_rulename(node, :typeref)

    push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  t = $(typerulename)(tvlookup, totv, false)::Type") # false avoids probabilistic expansion to union since it will be de-expanded in next few lines here
    push!(rule.source, "  dt = begin")
    push!(rule.source, "    if isa(t, Union)")
    push!(rule.source, "      @assert !isempty(t.types)") # not a Union{}
   	push!(rule.source, "      $(thisrulename)(tvlookup, t.types[choose(Int, 1, length(t.types))])")
   	push!(rule.source, "    else")
    # TODO - handle TypeConstructors here?
    push!(rule.source, "      t")
    push!(rule.source, "    end")
    push!(rule.source, "  end::DataType")
    push!(rule.source, "  @assert dt <: t") # <: here works for both Types and TypeVars
    # optionally resolve some typevars (and varargs) of this datatype
    push!(rule.source, "  newps = Vector{Any}()")
	push!(rule.source, "  for p in dt.parameters")
	push!(rule.source, "    if isa(p, TypeVar) && choose(Bool)")
	push!(rule.source, "      push!(newps, $(typerulename)(tvlookup, p, true))")
	push!(rule.source, "    elseif isa(p, DataType) && (p.name == Vararg.name) && choose(Bool)")
	push!(rule.source, "      while choose(Bool)") # should really use a mult for this, but this seems to lengthen compile-time dramatically (possibly type inference issue as in method rule?)
	push!(rule.source, "        if choose(Bool)")
	push!(rule.source, "          push!(newps, $(typerulename)(tvlookup, p.parameters[1], true))")
	push!(rule.source, "        end")
	push!(rule.source, "      end")
	push!(rule.source, "    else")
	push!(rule.source, "      push!(newps, p)")
	push!(rule.source, "    end")
	push!(rule.source, "  end")
	push!(rule.source, "  dt = DataGenerators.replace_datatype_parameters(dt, newps)::DataType")
    push!(rule.source, "  @assert dt <: t") # <: here works for both Types and TypeVars
    push!(rule.source, "  dt")
    
    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns a Type (or sometimes a value, e.g. when the TypeVar is for any array dimension or symbol) for the passed Type or TypeVar
function build_type_type(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "totv"; "unionise";]

    # thisrulename = build_called_rulename(node)
    dtrootrulename = build_called_child_rulename(node, :dtref)
    datatyperulename = build_called_child_rulename(node, :datatyperef)

    # push!(rule.source, "  @assert isa(totv, Union{Type, TypeVar})")
    push!(rule.source, "  begin")
	push!(rule.source, "    if isa(totv, TypeVar)")
    push!(rule.source, "      if totv.bound && haskey(tvlookup, totv)")
	push!(rule.source, "        tvlookup[totv]")
	push!(rule.source, "      else")
	push!(rule.source, "        t = begin")
	# Hardcode handling of TypeVar N
	push!(rule.source, "          if totv.name == :N")
	push!(rule.source, "            length(plus(:dummy))::Int") #TODO: for the moment, force dimensions to use a geometric distribution; #TODO also could allow 0
	push!(rule.source, "          else")
	push!(rule.source, "            if !unionise || choose(Bool)")
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

 	# push!(rule.source, "    elseif isa(totv, DataType)")
 	# push!(rule.source, "  newps = Vector{Any}()")
	# push!(rule.source, "  for p in totv.parameters")
	# push!(rule.source, "    if isa(p, TypeVar) && choose(Bool)")
	# push!(rule.source, "      push!(newps, $(thisrulename)(tvlookup, p, true))")
	# push!(rule.source, "    elseif isa(p, DataType) && (p.name == Vararg.name) && choose(Bool)")
	# push!(rule.source, "      while choose(Bool)") # should really use a mult for this, but this seems to lengthen compile-time dramatically (possibly type inference issue as in method rule?)
	# push!(rule.source, "        if choose(Bool)")
	# push!(rule.source, "          push!(newps, $(thisrulename)(tvlookup, p.parameters[1], true))")
	# push!(rule.source, "        end")
	# push!(rule.source, "      end")
	# push!(rule.source, "    else")
	# push!(rule.source, "      push!(newps, p)")
	# push!(rule.source, "    end")
	# push!(rule.source, "  end")
	# push!(rule.source, "  DataGenerators.replace_datatype_parameters(totv , newps)::DataType")

    push!(rule.source, "    else")
    push!(rule.source, "      totv")
    push!(rule.source, "    end")
    push!(rule.source, "  end")

    build_rule_end(rule, node)
    push!(rules, rule)
end


# returns the result of calling a method with a value of the given signature type
function build_type_method(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
    rule.args = ["tvlookup"; "dt"; "fname"; "sig";]

    #   fname is function name (Symbol)
    #   sig is method signature (DataType) - specifically a Tuple
    push!(rule.source, "  @assert sig <: Tuple")
    push!(rule.source, "  @assert isa(dt, DataType)")

    push!(rule.source, "  argstype = deepcopy(sig)")

    # ensure required datatype is fully parameterised (but not necessarily parameters of these types as parameters, i.e. only go one level deep)
    typerulename = build_called_child_rulename(node, :typeref)

    push!(rule.source, "  paramdt = DataGenerators.replace_datatype_parameters(dt, map(p -> $(typerulename)(tvlookup, p, true), dt.parameters))") # any bound typevars to be resolved will be in the old bound typevar context, so use that
	
    # create a new lookup context for bound typevars
    push!(rule.source, "  newtvlookup = Dict{TypeVar, Any}()") 

    push!(rule.source, "  if fname == :call")
    # if constructor method is a call, then we must match type to the first parameter of the signature tuple, and bind variables accordingly:
    push!(rule.source, "    @assert !isempty(argstype.parameters)")
    # note: first parameter of call may not have bound variables, so we force them to be as follows:
    push!(rule.source, "    boundtvs = filter(tv -> tv.bound, DataGenerators.extract_typevars(argstype))") # get all bound type variables in the args Tuple
    push!(rule.source, "    firstargtype = deepcopy(argstype.parameters[1])")
    push!(rule.source, "    firstargtype = DataGenerators.bind_matching_unbound_typevars(firstargtype, boundtvs)") # bind these if they occur in the first parameter
    push!(rule.source, "    DataGenerators.match_template_bound_typevars(firstargtype, Type{paramdt}, newtvlookup)") # and match them to value in the desired datatype
    # note: argstype remains unchanged
	push!(rule.source, "  end")

    push!(rule.source, "  argstype = DataGenerators.resolve_bound_typevars(argstype, newtvlookup)")
    # TODO also resolve unbound typevars (perhaps only some)

	valuerulename = build_called_child_rulename(node, :valueref)
	push!(rule.source, "  args = $(valuerulename)(newtvlookup, argstype)::Tuple") # note: newtvlookup

	# push!(rule.source, "  info(\"calling \$(fname) with signature \$(sig) with args \$(args) to get a value for datatype \$(paramdt))\")")
	push!(rule.source, "  f = eval(parse(\"\$(fname)\"))")
	push!(rule.source, "  try")
	push!(rule.source, "    invoke(f, sig, args...)::dt") # note: original sig
	# note dt, not paramdt, in type assert: we are okay if parameters are ignored (I think - unless they are bound??)
	push!(rule.source, "  catch exc")
	push!(rule.source, "    throw(DataGenerators.TypeGenerationException(symbol(\"$(node.func)\"), \"calling function \$(fname) with signature \$(sig) using args \$(args) to get a value for datatype \$(paramdt)\", exc))")
	push!(rule.source, "  end")
	

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
	    	push!(rule.source, "      if (dt.name == Type.name)")
	    	push!(rule.source, "        if (dt === ruleprimarydt)")
	    	push!(rule.source, "          if choose(Bool)") # sometimes treat primary as concrete rather than abstract since Type{T} an instance of Type
	    	datatyperulename = build_called_child_rulename(node, :datatyperef)
			push!(rule.source, "          	return $(datatyperulename)(tvlookup, dt)") # pass through datatyperulename to optionally parameterise
			push!(rule.source, "          end")
			push!(rule.source, "        else")
	    	typerulename = build_called_child_rulename(node, :typeref) # if not primary, then return first parameter (if it a TypeVar, will be expanded)
			push!(rule.source, "          return $(typerulename)(tvlookup, dt.parameters[1], true)")
			# note can unionise, e.g. isa(Union{Int8, Int16}, Type{TypeVar(:T, Integer)}) is true; 
			push!(rule.source, "        end")
			push!(rule.source, "      end")
		end
		push!(rule.source, "      $(chooserulename)(tvlookup, dtotv)")
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
		push!(rule.source, "    throw(DataGenerators.TypeGenerationException(symbol(\"$(node.func)\"), \"no applicable subtype rule for type \$(dt) in rule for $(ruleprimarydtstr)\"))")

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
	    # Might be able to use isa_tuple_adjust

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

			    valuerulename = build_called_child_rulename(node, :valueref)
		    	push!(rule.source, "  els = Vector{Any}()")
		    	push!(rule.source, "  for p in dt.parameters")
		    	push!(rule.source, "    if isa(p, DataType) && (p.name == Vararg.name)")
		    	push!(rule.source, "       append!(els, mult($(valuerulename)(tvlookup, p.parameters[1])))")
		    	push!(rule.source, "    else")
		    	push!(rule.source, "       push!(els, $(valuerulename)(tvlookup, p))")
		    	push!(rule.source, "    end")
		    	push!(rule.source, "  end")
		    	push!(rule.source, "  (els...)")

		    elseif primarydt == DataType

		    	# to return a datatype, we simply call the  datatype rule with a TypeVar T<:Any in order to return one
		    	# of the datatypes (abstract or concrete) in the tree
		    	# NB datatype rule (as opposed to dtrootrule) will also optionally resolve some TypeVars
			    datatyperulename = build_called_child_rulename(node, :datatyperef)
		    	push!(rule.source, "  $(datatyperulename)(tvlookup, TypeVar(gensym(), Any))")

		    elseif primarydt == Union

		    	# note: 
		    	#  a) Union{S,T} is not a subtype of Union (and nor, therefore, Type)
		    	#  b) instead, Union{S,T} is an value of Union
		    	#  c) Union{} is an value of Union
			    
			    datatyperulename = build_called_child_rulename(node, :datatyperef)
			    # build union for a sequence of 2 or more datatypes (see below re 0 datatypes, i,e. Union{}; union of 1 datatype is that datatype)
				# push!(rule.source, "  u = Union{reps($(datatyperulename)(tvlookup, TypeVar(gensym(), Any)),2)...}")
				# as a workaround, need to do this using a loop as choose Bool since reps seems to cause lengthy compilation
				push!(rule.source, "  dts = DataType[]")
				push!(rule.source, "  while (length(dts) < 2) || choose(Bool)")
				# could also create union and thereby check on whether it is not a datatype as we go, but this could cause
				# an endless loop in the rare case that we have only one datatype to choose from
				push!(rule.source, "  	push!(dts, $(datatyperulename)(tvlookup, TypeVar(gensym(), Any)))")
				push!(rule.source, "  end")
				push!(rule.source, "  u = Union{dts...}")
				# entirely possible that this still simplifies to a single datatype, in which case return Union{}
				push!(rule.source, "  (isa(u, DataType) ? Union{} : u)::Union")

		    else

		    	@assert false

		    end

		else

	    	push!(rule.comments, "#TODO write custom constructor method for type $(primarydt)")
	    	push!(rule.source, "    throw(DataGenerators.TypeGenerationException(symbol(\"$(node.func)\"), \"no constructor method for type $(primarydt)\"))")

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


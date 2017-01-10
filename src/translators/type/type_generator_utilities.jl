
# functions called by rule code in translated type generators

# TODO can do this more explicitly by matching parameter names?
function apply_type_parameters_to_primary(primarydt::DataType, dt::DataType)
	if (primarydt.name == Tuple.name)
		# because typeintersect(Tuple, Tuple{TypeVar(:S, Signed, true), TypeVar(:S, Signed, true)}) gives Tuple{_,_}, which isn't what is required
		dt
	else
		typeintersect(primarydt, dt)
	end
end


function match_template_bound_typevars(template::TypeVar, actual::Any, tvlookup::Dict{TypeVar, Any} = Dict{TypeVar, Any}())
	@assert !isa(actual, Type) || (template.lb <: actual <: template.ub)
	@assert !haskey(tvlookup, template)
	tvlookup[template] = actual
	tvlookup
end

function match_template_bound_typevars(template::DataType, actual::DataType, tvlookup::Dict{TypeVar, Any} = Dict{TypeVar, Any}())
	@assert datatype_name(template) == datatype_name(actual)
	@assert length(template.parameters) == length(actual.parameters)
	for i in 1:length(template.parameters)
		match_template_bound_typevars(template.parameters[i], actual.parameters[i], tvlookup)
	end
	tvlookup
end

function match_template_bound_typevars(template::Union, actual::Union, tvlookup::Dict{TypeVar, Any} = Dict{TypeVar, Any}())
	@assert length(template.types) == length(actual.types)
	for i in 1:length(template.types)
		match_template_bound_typevars(template.types[i], actual.types[i], tvlookup)
	end
	tvlookup
end

function match_template_bound_typevars(template::Any, actual::Any, tvlookup::Dict{TypeVar, Any} = Dict{TypeVar, Any}())
	@assert template == actual
	tvlookup
end


resolve_bound_typevars(tv::TypeVar, tvlookup::Dict{TypeVar, Any}) = (tv.bound && haskey(tvlookup, tv)) ? tvlookup[tv] : tv

resolve_bound_typevars(dt::DataType, tvlookup::Dict{TypeVar, Any}) = primary_datatype(dt){map(p -> resolve_bound_typevars(p, tvlookup), dt.parameters)...}

resolve_bound_typevars(u::Union, tvlookup::Dict{TypeVar, Any}) = Union{map(t -> resolve_bound_typevars(t, tvlookup), u.types)...}

resolve_bound_typevars(x::Any, tvlookup::Dict{TypeVar, Any}) = x


function extract_typevars(tv::TypeVar, tvs::Vector{TypeVar} = Vector{TypeVar}())
	if !(tv in tvs)
		push!(tvs, tv)
	end
	tvs
end

function extract_typevars(dt::DataType, tvs::Vector{TypeVar} = Vector{TypeVar}())
	for p in dt.parameters
		extract_typevars(p, tvs)
	end
	tvs
end

function extract_typevars(u::Union, tvs::Vector{TypeVar} = Vector{TypeVar}())
	for t in u.types
		extract_typevars(t, tvs)
	end
	tvs
end

extract_typevars(x::Any, tvs::Vector{TypeVar} = Vector{TypeVar}()) = tvs


function bind_matching_unbound_typevars(tv::TypeVar, boundtvs::Vector{TypeVar})
	if !tv.bound
		for boundtv in boundtvs
			if (boundtv.name == tv.name) && (boundtv.lb == tv.lb) && (boundtv.ub == tv.ub)
				return boundtv
			end
		end
	end
	tv
end


bind_matching_unbound_typevars(dt::DataType, boundtvs::Vector{TypeVar}) = primary_datatype(dt){map(p -> bind_matching_unbound_typevars(p, boundtvs), dt.parameters)...}

bind_matching_unbound_typevars(u::Union, boundtvs::Vector{TypeVar}) = Union{map(t -> bind_matching_unbound_typevars(t, boundtvs), u.types)...}

bind_matching_unbound_typevars(x::Any, boundtvs::Vector{TypeVar}) = x


function replace_datatype_parameters(dt::DataType, ps::Vector{Any})
	if datatype_name(dt) == datatype_name(Union)
		dt   # since Union is not the same as Union{} - the former is a DataType, the latter is not
	else
		primary_datatype(dt){ps...}
	end::DataType
end




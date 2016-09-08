primary_datatype(t::DataType) = t.name.primary

is_abstract_type(t::DataType) = t.abstract

function extract_primary_datatypes(t::Type)
	datatypes = Vector{DataType}()
	typevardatatypes = Vector{DataType}()
	extract_primary_datatypes(t, datatypes, typevardatatypes)
	datatypes, typevardatatypes
end

function extract_primary_datatypes(t::DataType, datatypes::Vector{DataType}, typevardatatypes::Vector{DataType})
	push!(datatypes, primary_datatype(t))
	for p in t.parameters 
		extract_primary_datatypes(p, datatypes, typevardatatypes)
	end
end

function extract_primary_datatypes(t::Union, datatypes::Vector{DataType}, typevardatatypes::Vector{DataType})
	for p in t.types
		extract_primary_datatypes(p, datatypes, typevardatatypes)
	end
end

function extract_primary_datatypes(t::TypeVar, datatypes::Vector{DataType}, typevardatatypes::Vector{DataType})
	push!(typevardatatypes, primary_datatype(t.ub))
end

function extract_primary_datatypes(t::Any, datatypes::Vector{DataType}, typevardatatypes::Vector{DataType})
	# do nothing (catch all needed for e.g. array dimensions which are Int values)
end

# remove any subtypes we explicitly don't want to handle
function supportable_subtypes(t::DataType)
	filter(st -> (
			(st != Any)						# because Any is a subtype of itself and so this could trigger infinite recursion (Any is handled as a special case anyway)
			&& (st != TypeConstructor)		# 'special' type (note: TypeConstructor <: Type{T}, but not when T is explicit)
			&& !(st <: DataGenerators.Generator)
			# && Base.isexported(st.name.module, st.name.name) # TODO (throughout) check which context should be used for this since generator is evaluated when the context of a module
		), subtypes(current_module(), t)) # TODO (throughout) check which context should be used for this since generator is evaluated when the context of a module
end

function merge_datatypes_up(ts::Vector{DataType})
	if isempty(ts)
		return ts
	else
		if length(ts) > 1
			for i in 2:length(ts)
				if ts[1] <: ts[i]
					return merge_datatypes_up(ts[2:end])
				end
				if ts[i] <: ts[1]
					ts[i] = ts[1]
					return merge_datatypes_up(ts[2:end])
				end
			end
		end
		[ts[1]; merge_datatypes_up(ts[2:end])]
	end
end

function merge_datatypes_down(ts::Vector{DataType})
	if isempty(ts)
		return ts
	else
		if length(ts) > 1
			for i in 2:length(ts)
				if ts[1] <: ts[i]
					ts[i] = ts[1]
					return merge_datatypes_down(ts[2:end])
				end
				if ts[i] <: ts[1]
					return merge_datatypes_down(ts[2:end])
				end
			end
		end
		[ts[1]; merge_datatypes_down(ts[2:end])]
	end
end

function is_partially_supported(supporteddts::Vector{DataType}, t::DataType)
	for supporteddt in supporteddts
		if typeintersect(supporteddt, t) != Union{}
			return true
		end
	end
	false
end

function is_partially_supported(supporteddts::Vector{DataType}, ts::Vector{DataType})
	for t in ts
		if !is_partially_supported(supporteddts, t)
			return false
		end
	end
	true
end

function is_partially_supported(supporteddts::Vector{DataType}, m::Method)
	datatypes, typevardatatypes = extract_primary_datatypes(m.sig)
	is_partially_supported(supporteddts, [datatypes; typevardatatypes])
end

function partially_supported_constructor_methods(supporteddts::Vector{DataType}, dt::DataType)
	filter(m->is_partially_supported(supporteddts, m), methods(dt)) # TODO restrict by module?  # TODO other filters (e.g. deprecated)
end

function type_as_parseable_string(t::Type)
	str = ""
	paramstrs = AbstractString[]
	if isa(t, DataType)
		str *= string(t.name.name)
		if t != t.name.primary
			for parameter in t.parameters
				if isa(parameter, Type)
					push!(paramstrs, type_as_parseable_string(parameter))
				elseif isa(parameter, Number)
					push!(paramstrs, string(parameter))
				else
					break;
				end
			end
		end
	elseif isa(t, Union)
		str = "Union"
		for typ in t.types
			if isa(parameter, Type)
				push!(paramstrs, type_as_parseable_string(parameter))
			else
				break;
			end
		end
	else
		error("unexpected subtype of Type")
	end
	if !isempty(paramstrs) || isa(t, Union)
		str *= "{" * join(paramstrs, ",") * "}"
	end
	str
end


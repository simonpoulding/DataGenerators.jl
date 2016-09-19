# TODO: add comments (including assumptions, and quirks of subtype)

datatype_name(dt::DataType) = dt.name

primary_datatype(dt::DataType) = datatype_name(dt).primary

is_abstract(dt::DataType) = dt.abstract

function isa_tuple_adjust(x::Any, t::Type)
	if !isa(t, DataType) || (t.name != Tuple.name) || (t === Tuple)
		isa(x, t)
	else
		if !isa(x, Tuple)
			return false
		end
		xidx = 1
		pidx = 1
		ps = collect(t.parameters)
		while xidx <= length(x)
			if pidx > length(ps)
				return false
			end
			if !isa(x[xidx], isa(ps[pidx], TypeVar) ? ps[pidx].ub : (ps[pidx].name == Vararg.name) ? ps[pidx].parameters[1] : ps[pidx])
				return false
			end
			xidx += 1
			if ps[pidx].name != Vararg.name 
				pidx += 1
			end
		end
		(pidx == length(ps)+1) || ((pidx <= length(ps)) && (ps[pidx].name == Vararg.name))
	end
end


function datatype_tree_ascend(dt::DataType, dttree::Dict{DataType, Vector{DataType}} = Dict{DataType, Vector{DataType}}())
	if dt != Any
		superdt = super(dt)
		v = get!(dttree, superdt, Vector{DataType}[])
		if !(dt in v)
			push!(v, dt)
		end
		datatype_tree_ascend(superdt::DataType, dttree)
	end
	dttree
end

function datatype_tree_descend(dt::DataType, dttree::Dict{DataType, Vector{DataType}} = Dict{DataType, Vector{DataType}}(); subtypefn=subtypes)
	v = get!(dttree, dt, Vector{DataType}[])
	for subdt in subtypefn(dt)
		if subdt != Any
			if !(subdt in v)
				push!(v, subdt)
			end
			datatype_tree_descend(subdt::DataType, dttree; subtypefn=subtypefn)
		end
	end
	dttree
end

function datatype_tree(dt::DataType, dttree::Dict{DataType, Vector{DataType}} = Dict{DataType, Vector{DataType}}(); subtypefn=subtypes)
	datatype_tree_ascend(dt, dttree)
	datatype_tree_descend(dt, dttree; subtypefn=subtypefn)
	dttree
end

function datatype_tree(dts::Vector{DataType}, dttree::Dict{DataType, Vector{DataType}} = Dict{DataType, Vector{DataType}}(); subtypefn=subtypes)
	for dt in dts
		datatype_tree(dt::DataType, dttree; subtypefn=subtypefn)
	end
	dttree
end



function nonabstract_descendents(dt::DataType, descendents::Vector{DataType} = Vector{DataType}(); subtypefn=subtypes)
	if !is_abstract(dt)
		if !(dt in descendents)
			push!(descendents, dt)
		end
	else
		for subdt in subtypefn(dt)
			if subdt != Any
				nonabstract_descendents(subdt::DataType, descendents; subtypefn=subtypefn)
			end
		end
	end
	descendents
end

function nonabstract_descendents(dts::Vector{DataType}, descendents::Vector{DataType} = Vector{DataType}(); subtypefn=subtypes)
	for dt in dts
		nonabstract_descendents(dt::DataType, descendents; subtypefn=subtypefn)
	end
	descendents
end


function extract_primary_datatypes(dt::DataType, pdts::Vector{DataType} = Vector{DataType}())
	pdt = primary_datatype(dt)
	if !(pdt in pdts)
		push!(pdts, pdt)
	end
	for p in dt.parameters 
		extract_primary_datatypes(p, pdts)
	end
	pdts
end

function extract_primary_datatypes(ts::Vector{Type}, pdts::Vector{DataType} = Vector{DataType}())
	for t in ts
		extract_primary_datatypes(t, pdts)
	end
	pdts
end

function extract_primary_datatypes(u::Union, pdts::Vector{DataType} = Vector{DataType}())
	for t in u.types
		extract_primary_datatypes(t, pdts)
	end
	pdts
end

function extract_primary_datatypes(tv::TypeVar, pdts::Vector{DataType} = Vector{DataType}())
	extract_primary_datatypes(tv.ub, pdts)
	extract_primary_datatypes(tv.lb, pdts) # since Union{} is a Union rather than a DataType, and it contains no types, it will contribute nothing
	pdts
end

function extract_primary_datatypes(t::Any, pdts::Vector{DataType} = Vector{DataType}())
	# do nothing (catch all needed for e.g. array dimensions which are numeric values)
	pdts
end


function merge_datatypes_up(dts::Vector{DataType})
	if isempty(dts)
		return dts
	else
		if length(dts) > 1
			for i in 2:length(dts)
				if dts[1] <: dts[i]
					return merge_datatypes_up(dts[2:end])
				end
				if dts[i] <: dts[1]
					dts[i] = dts[1]
					return merge_datatypes_up(dts[2:end])
				end
			end
		end
		[dts[1]; merge_datatypes_up(dts[2:end])]
	end
end

function merge_datatypes_down(dts::Vector{DataType})
	if isempty(dts)
		return dts
	else
		if length(dts) > 1
			for i in 2:length(dts)
				if dts[1] <: dts[i]
					dts[i] = dts[1]
					return merge_datatypes_down(dts[2:end])
				end
				if dts[i] <: dts[1]
					return merge_datatypes_down(dts[2:end])
				end
			end
		end
		[dts[1]; merge_datatypes_down(dts[2:end])]
	end
end


is_partially_supported(dt::DataType, supporteddts::Vector{DataType}) = any(supportedt->typeintersect(supportedt, dt) != Union{}, supporteddts)

is_partially_supported(dts::Vector{DataType}, supporteddts::Vector{DataType}) = all(dt -> is_partially_supported(dt, supporteddts), dts)

function is_partially_supported(m::Method, supporteddts::Vector{DataType})
	dts = extract_primary_datatypes(m.sig)
	is_partially_supported(dts, supporteddts)
end

function partially_supported_constructor_methods(dt::DataType, supporteddts::Vector{DataType})
	filter(m->is_partially_supported(m, supporteddts), methods(dt)) # TODO restrict by module?  # TODO other filters (e.g. deprecated)
end



type_as_parseable_string(tv::TypeVar) = "TypeVar(symbol(\"" * string(tv.name) * "\")," * type_as_parseable_string(tv.lb) * "," * type_as_parseable_string(tv.ub) * "," * (tv.bound ? "true" : "false") * ")"

type_as_parseable_string(dt::DataType) = string(dt.name.name) * (dt === primary_datatype(dt) ? "" : "{" * join(map(p -> type_as_parseable_string(p), dt.parameters), ",") * "}") # note: === rather than == on testing primary datatypes is necessary to ensure parameters match (e.g. bound/unbound TypeVars)

type_as_parseable_string(u::Union) = "Union" * "{" * join(map(p -> type_as_parseable_string(p), u.types), ",") * "}" # note: Union{} is distinct from Union, so always output the curly braces

type_as_parseable_string(x::Any) = string(x)



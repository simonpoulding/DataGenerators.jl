@generator TypeGen begin

generates: ["an instance of type Tuple{S<:Signed,S<:Signed}"]

start() = begin
  tvlookup = Dict{TypeVar, Any}()
  start_1_value(tvlookup, Tuple{TypeVar(symbol("S"),Union{},Signed,true),TypeVar(symbol("S"),Union{},Signed,true)})
end

start_1_value(tvlookup, totv) = begin
  @assert isa(totv, Union{Type, TypeVar})
  dt = eval(Expr(:call, _stateparam.generator.rulemethodnames[symbol("start_2_datatype")], _genparam, _stateparam, tvlookup, totv))::DataType
  eval(Expr(:call, _stateparam.generator.rulemethodnames[symbol("start_5_dt_Any")], _genparam, _stateparam, tvlookup, dt))
end

start_2_datatype(tvlookup, totv) = begin
  @assert isa(totv, Union{Type, TypeVar})
  t = start_3_type(tvlookup, totv, false)::Type
  dt = begin
    if isa(t, Union)
      @assert !isempty(t.types)
      start_2_datatype(tvlookup, t.types[choose(Int, 1, length(t.types))])
    else
      t
    end
  end::DataType
  @assert dt <: t
  newps = Vector{Any}()
  for p in dt.parameters
    if isa(p, TypeVar) && choose(Bool)
      push!(newps, start_3_type(tvlookup, p, true))
    elseif isa(p, DataType) && (p.name == Vararg.name) && choose(Bool)
      while choose(Bool)
        if choose(Bool)
          push!(newps, start_3_type(tvlookup, p.parameters[1], true))
        end
      end
    else
      push!(newps, p)
    end
  end
  dt = DataGenerators.replace_datatype_parameters(dt, newps)::DataType
  @assert dt <: t
  dt
end

start_3_type(tvlookup, totv, unionise) = begin
  begin
    if isa(totv, TypeVar)
      if totv.bound && haskey(tvlookup, totv)
        tvlookup[totv]
      else
        t = begin
          if totv.name == :N
            length(plus(:dummy))::Int
          else
            if !unionise || choose(Bool)
              @assert totv.lb == Union{}
              dt = start_2_datatype(tvlookup, totv.ub)::DataType
              start_5_dt_Any(tvlookup, TypeVar(gensym(totv.name), dt))::DataType
            else
              Union{TypeVar(gensym(totv.name), totv.lb, totv.ub, totv.bound), TypeVar(gensym(totv.name), totv.lb, totv.ub, totv.bound)}
            end
          end
        end
        if totv.bound
           tvlookup[totv] = t
        end
        t
      end
    else
      totv
    end
  end
end

start_4_method(tvlookup, dt, fname, sig) = begin
  @assert sig <: Tuple
  @assert isa(dt, DataType)
  argstype = deepcopy(sig)
   paramdt = DataGenerators.replace_datatype_parameters(dt, map(p -> start_3_type(tvlookup, p, true), dt.parameters))
  newtvlookup = Dict{TypeVar, Any}()
  if fname == :call
    @assert !isempty(argstype.parameters)
    boundtvs = filter(tv -> tv.bound, DataGenerators.extract_typevars(argstype))
    firstargtype = deepcopy(argstype.parameters[1])
    firstargtype = DataGenerators.bind_matching_unbound_typevars(firstargtype, boundtvs)
    DataGenerators.match_template_bound_typevars(firstargtype, Type{paramdt}, newtvlookup)
  end
  argstype = DataGenerators.resolve_bound_typevars(argstype, newtvlookup)
  args = start_1_value(newtvlookup, argstype)::Tuple
  f = eval(parse("$(fname)"))
  try
    invoke(f, sig, args...)::dt
  catch exc
    throw(DataGenerators.TypeGenerationException(symbol("method"), "calling function $(fname) with signature $(sig) using args $(args) to get a value for datatype $(paramdt)", exc))
  end
end

# Any
start_5_dt_Any(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Any::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if ruleprimarydt <: dt.name.primary
    if isa(dtotv, TypeVar) && choose(Bool)
      DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    else
      start_5_dt_Any_4_choose(tvlookup, dtotv)
    end
  else
    (dt <: Number) ? start_5_dt_Any_1_dt_Number(tvlookup, dtotv) :
    (dt <: Tuple) ? start_5_dt_Any_2_dt_Tuple(tvlookup, dtotv) :
    (dt <: Type) ? start_5_dt_Any_3_dt_Type(tvlookup, dtotv) :
    throw(DataGenerators.TypeGenerationException(symbol("dt"), "no applicable subtype rule for type $(dt) in rule for Any"))
  end
end

# Number
start_5_dt_Any_1_dt_Number(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Number::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if ruleprimarydt <: dt.name.primary
    if isa(dtotv, TypeVar) && choose(Bool)
      DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    else
      start_5_dt_Any_1_dt_Number_2_choose(tvlookup, dtotv)
    end
  else
    (dt <: Real) ? start_5_dt_Any_1_dt_Number_1_dt_Real(tvlookup, dtotv) :
    throw(DataGenerators.TypeGenerationException(symbol("dt"), "no applicable subtype rule for type $(dt) in rule for Number"))
  end
end

# Real
start_5_dt_Any_1_dt_Number_1_dt_Real(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Real::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if ruleprimarydt <: dt.name.primary
    if isa(dtotv, TypeVar) && choose(Bool)
      DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    else
      start_5_dt_Any_1_dt_Number_1_dt_Real_2_choose(tvlookup, dtotv)
    end
  else
    (dt <: Integer) ? start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer(tvlookup, dtotv) :
    throw(DataGenerators.TypeGenerationException(symbol("dt"), "no applicable subtype rule for type $(dt) in rule for Real"))
  end
end

# Integer
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Integer::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if ruleprimarydt <: dt.name.primary
    if isa(dtotv, TypeVar) && choose(Bool)
      DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    else
      start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_2_choose(tvlookup, dtotv)
    end
  else
    (dt <: Signed) ? start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed(tvlookup, dtotv) :
    throw(DataGenerators.TypeGenerationException(symbol("dt"), "no applicable subtype rule for type $(dt) in rule for Integer"))
  end
end

# Signed
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Signed::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if ruleprimarydt <: dt.name.primary
    if isa(dtotv, TypeVar) && choose(Bool)
      DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    else
      start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_6_choose(tvlookup, dtotv)
    end
  else
    (dt <: Int128) ? start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_1_dt_Int128(tvlookup, dtotv) :
    (dt <: Int16) ? start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_2_dt_Int16(tvlookup, dtotv) :
    (dt <: Int32) ? start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_3_dt_Int32(tvlookup, dtotv) :
    (dt <: Int64) ? start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_4_dt_Int64(tvlookup, dtotv) :
    (dt <: Int8) ? start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_5_dt_Int8(tvlookup, dtotv) :
    throw(DataGenerators.TypeGenerationException(symbol("dt"), "no applicable subtype rule for type $(dt) in rule for Signed"))
  end
end

# Int128
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_1_dt_Int128(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Int128::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_1_dt_Int128_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method call{T}(::Type{T}, arg) at essentials.jl:56
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_1_dt_Int128_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  start_4_method(tvlookup, dt, symbol("call"), Tuple{Type{TypeVar(symbol("T"),Union{},Any,true)},Any})
end

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_1_dt_Int128_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_1_dt_Int128_1_cm(tvlookup, p)

# Int16
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_2_dt_Int16(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Int16::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_2_dt_Int16_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype Int16
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_2_dt_Int16_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  choose(Int16)
end

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_2_dt_Int16_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_2_dt_Int16_1_cm(tvlookup, p)

# Int32
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_3_dt_Int32(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Int32::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_3_dt_Int32_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype Int32
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_3_dt_Int32_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  choose(Int32)
end

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_3_dt_Int32_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_3_dt_Int32_1_cm(tvlookup, p)

# Int64
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_4_dt_Int64(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Int64::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_4_dt_Int64_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype Int64
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_4_dt_Int64_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  choose(Int64)
end

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_4_dt_Int64_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_4_dt_Int64_1_cm(tvlookup, p)

# Int8
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_5_dt_Int8(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Int8::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_5_dt_Int8_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype Int8
start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_5_dt_Int8_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  choose(Int8)
end

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_5_dt_Int8_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_5_dt_Int8_1_cm(tvlookup, p)

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_6_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_1_dt_Int128(tvlookup, p)

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_6_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_2_dt_Int16(tvlookup, p)

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_6_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_3_dt_Int32(tvlookup, p)

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_6_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_4_dt_Int64(tvlookup, p)

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_6_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed_5_dt_Int8(tvlookup, p)

start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer_1_dt_Signed(tvlookup, p)

start_5_dt_Any_1_dt_Number_1_dt_Real_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real_1_dt_Integer(tvlookup, p)

start_5_dt_Any_1_dt_Number_2_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number_1_dt_Real(tvlookup, p)

# Tuple
start_5_dt_Any_2_dt_Tuple(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Tuple::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_2_dt_Tuple_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype Tuple
start_5_dt_Any_2_dt_Tuple_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  els = Vector{Any}()
  for p in dt.parameters
    if isa(p, DataType) && (p.name == Vararg.name)
       append!(els, mult(start_1_value(tvlookup, p.parameters[1])))
    else
       push!(els, start_1_value(tvlookup, p))
    end
  end
  (els...)
end

start_5_dt_Any_2_dt_Tuple_2_choose(tvlookup, p) = start_5_dt_Any_2_dt_Tuple_1_cm(tvlookup, p)

# Type
start_5_dt_Any_3_dt_Type(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Type::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if ruleprimarydt <: dt.name.primary
    if isa(dtotv, TypeVar) && choose(Bool)
      DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    else
      if (dt.name == Type.name)
        if (dt === ruleprimarydt)
          if choose(Bool)
          	return start_2_datatype(tvlookup, dt)
          end
        else
          return start_3_type(tvlookup, dt.parameters[1], true)
        end
      end
      start_5_dt_Any_3_dt_Type_6_choose(tvlookup, dtotv)
    end
  else
    (dt <: DataType) ? start_5_dt_Any_3_dt_Type_1_dt_DataType(tvlookup, dtotv) :
    (dt <: TypeConstructor) ? start_5_dt_Any_3_dt_Type_2_dt_TypeConstructor(tvlookup, dtotv) :
    (dt <: Union) ? start_5_dt_Any_3_dt_Type_3_dt_Union(tvlookup, dtotv) :
    throw(DataGenerators.TypeGenerationException(symbol("dt"), "no applicable subtype rule for type $(dt) in rule for Type"))
  end
end

# DataType
start_5_dt_Any_3_dt_Type_1_dt_DataType(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = DataType::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_3_dt_Type_1_dt_DataType_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype DataType
start_5_dt_Any_3_dt_Type_1_dt_DataType_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  start_2_datatype(tvlookup, TypeVar(gensym(), Any))
end

start_5_dt_Any_3_dt_Type_1_dt_DataType_2_choose(tvlookup, p) = start_5_dt_Any_3_dt_Type_1_dt_DataType_1_cm(tvlookup, p)

# TypeConstructor
start_5_dt_Any_3_dt_Type_2_dt_TypeConstructor(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = TypeConstructor::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_3_dt_Type_2_dt_TypeConstructor_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype TypeConstructor
# #TODO write custom constructor method for type TypeConstructor
start_5_dt_Any_3_dt_Type_2_dt_TypeConstructor_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
    throw(DataGenerators.TypeGenerationException(symbol("cm"), "no constructor method for type TypeConstructor"))
end

start_5_dt_Any_3_dt_Type_2_dt_TypeConstructor_2_choose(tvlookup, p) = start_5_dt_Any_3_dt_Type_2_dt_TypeConstructor_1_cm(tvlookup, p)

# Union
start_5_dt_Any_3_dt_Type_3_dt_Union(tvlookup, dtotv) = begin
  @assert isa(dtotv, Union{DataType, TypeVar})
  const ruleprimarydt = Union::DataType
  dt = (isa(dtotv, TypeVar) ? dtotv.ub : dtotv)::DataType
  if isa(dtotv, TypeVar)
    DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
  else
    parameteriseddt = DataGenerators.apply_type_parameters_to_primary(ruleprimarydt, dt)
    start_5_dt_Any_3_dt_Type_3_dt_Union_2_choose(tvlookup, parameteriseddt)
  end
end

# constructor method for datatype Union
start_5_dt_Any_3_dt_Type_3_dt_Union_1_cm(tvlookup, dt) = begin
  @assert isa(dt, DataType)
  dts = DataType[]
  while (length(dts) < 2) || choose(Bool)
  	push!(dts, start_2_datatype(tvlookup, TypeVar(gensym(), Any)))
  end
  u = Union{dts...}
  (isa(u, DataType) ? Union{} : u)::Union
end

start_5_dt_Any_3_dt_Type_3_dt_Union_2_choose(tvlookup, p) = start_5_dt_Any_3_dt_Type_3_dt_Union_1_cm(tvlookup, p)

start_5_dt_Any_3_dt_Type_6_choose(tvlookup, p) = start_5_dt_Any_3_dt_Type_1_dt_DataType(tvlookup, p)

start_5_dt_Any_3_dt_Type_6_choose(tvlookup, p) = start_5_dt_Any_3_dt_Type_2_dt_TypeConstructor(tvlookup, p)

start_5_dt_Any_3_dt_Type_6_choose(tvlookup, p) = start_5_dt_Any_3_dt_Type_3_dt_Union(tvlookup, p)

start_5_dt_Any_4_choose(tvlookup, p) = start_5_dt_Any_1_dt_Number(tvlookup, p)

start_5_dt_Any_4_choose(tvlookup, p) = start_5_dt_Any_2_dt_Tuple(tvlookup, p)

start_5_dt_Any_4_choose(tvlookup, p) = start_5_dt_Any_3_dt_Type(tvlookup, p)

end

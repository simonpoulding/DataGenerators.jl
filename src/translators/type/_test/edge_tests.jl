using DataGenerators
using Base.Test

include("test_utilities.jl")

sd = false
se = false

try_generating_for_type(Type{Int8}, showdatum=sd, showerror=se)

try_generating_for_type(Type{TypeVar(:T, Integer)}, showdatum=sd, showerror=se)

try_generating_for_type(DataType, Type[Number], showdatum=sd, showerror=se)

try_generating_for_type(Union, Type[Number], showdatum=sd, showerror=se)

try_generating_for_type(Type, Type[Number], showdatum=sd, showerror=se)

try_generating_for_type(Type{TypeVar(:T, Signed)}, Type[Number], showdatum=sd, showerror=se)

try_generating_for_type(Type{Any}, Type[Number], showdatum=sd, showerror=se)

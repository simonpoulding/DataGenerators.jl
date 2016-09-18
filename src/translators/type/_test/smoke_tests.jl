using DataGenerators
using Base.Test

include("test_utilities.jl")

sd = false
se = false

try_generating_for_type(Int16, showdatum=sd, showerror=se)

try_generating_for_type(Union{Int8, UInt16}, showdatum=sd, showerror=se)

try_generating_for_type(Tuple{Int32, ASCIIString}, showdatum=sd, showerror=se)

try_generating_for_type(Signed, showdatum=sd, showerror=se)

try_generating_for_type(Tuple, Type[Int64, ASCIIString], showdatum=sd, showerror=se)

try_generating_for_type(Tuple{TypeVar(:S, Signed, true), TypeVar(:S, Signed, true)}, showdatum=sd, showerror=se)

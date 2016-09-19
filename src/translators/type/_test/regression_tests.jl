using DataGenerators
using Base.Test

include("test_utilities.jl")

sd = false
se = false


try_generating_for_type(Signed, showdatum=sd, showerror=se)

try_generating_for_type(Any, Type[Number], showdatum=sd, showerror=se)

try_generating_for_type(Union{Int8, UInt16}, showdatum=sd, showerror=se)

try_generating_for_type(Tuple{Int32, ASCIIString}, showdatum=sd, showerror=se)

try_generating_for_type(Type{Unsigned}, Type[Number], showdatum=sd, showerror=se)

try_generating_for_type(Tuple{TypeVar(:S, Signed, false), TypeVar(:S, Signed, false)}, showdatum=sd, showerror=se)

try_generating_for_type(Tuple{TypeVar(:S, Signed, true), TypeVar(:T, Signed, true)}, showdatum=sd, showerror=se)

try_generating_for_type(Tuple{TypeVar(:S, Signed, true), TypeVar(:S, Signed, true)}, showdatum=sd, showerror=se)

try_generating_for_type(Tuple{TypeVar(:S, Signed, true), Type{TypeVar(:S, Signed, true)}}, showdatum=sd, showerror=se)

try_generating_for_type(Tuple{TypeVar(:S, Signed, false), Type{TypeVar(:T, Signed, false)}}, showdatum=sd, showerror=se)

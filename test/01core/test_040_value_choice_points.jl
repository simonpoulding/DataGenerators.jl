# tests value choice points, i.e. using choose(DataType) construct

using GodelTest

# TODO to avoid repetition, would like to construct tests for types using metaprogramming
# HOWEVER, this works with Expressions constructed without interpolation, but as soon as
# interpolation is performed:
# (a) an explicit macroexpand is required before the eval
# (b) even then, either (GodelTest.)choose is not recognised or, if instead Autotest.eval is explicitly using, then (GodelTest.)gen is not recognised - a scoping issue/bug?
# And it does not appear to be possible to manipulate code as a string as an alternative (using parse, then eval)
#
# NOTE: For this reason, currently only the most common types are tested, and even within these, not all
# combinations of parameters are tested

@generator VCBoolGen begin # prefix VC (for Value Choice points) to avoid type name clashes
    start() = choose(Bool)
end

@testset "choose(Bool)" begin

    gn = VCBoolGen()

    @testset "emits different Boolean" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Bool
    #@mcheck_values_vary td
end
	
end


@generator VCIntGen begin
    start() = choose(Int,-1000,2000)
end

@testset "choose(Int)" begin

gn = VCIntGen()

@testset "emits different Int restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Int
    @test -1000 <= td <= 2000
    #@mcheck_values_vary td
end

end


@generator VCIntNonLiteralGen begin
    start() = choose(Int,-10*100,2*1000)
end

@testset "choose(Int) using range defined by non-literals" begin

gn = VCIntNonLiteralGen()

@testset "emits different Int restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Int
    @test -1000 <= td <= 2000
    #@mcheck_values_vary td
end

end


@generator VCIntVariableGen begin
    start() = choose(Int,-1000,2000)
    x() = -1000
    y() = 2000
end

@testset "choose(Int) using range defined by variables" begin

gn = VCIntVariableGen()

@testset "emits different Int restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Int
    @test -1000 <= td <= 2000
    #@mcheck_values_vary td
end

end


@generator VCIntNoMaxGen begin
    start() = choose(Int,-1000)
end

@testset "choose(Int) with no max specified" begin

gn = VCIntNoMaxGen()

@testset "emits different Int greater than or equal to min" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Int
    @test -1000 <= td
    #@mcheck_values_vary td
end

end


@generator VCIntNoRangeGen begin
    start() = choose(Int)
end

@testset "choose(Int) with no min nor max specified" begin

gn = VCIntNoRangeGen()

@testset "emits different Int without restriction" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Int
    #@mcheck_values_vary td
end

end


@generator VCInt64Gen begin
    start() = choose(Int64,-1000,2000)
end

@testset "choose(Int64)" begin

gn = VCInt64Gen()

@testset "emits different Int restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Int
    @test -1000 <= td <= 2000
    #@mcheck_values_vary td
end

end


@generator VCInt32Gen begin
    start() = choose(Int32,-1000,2000)
end

@testset "choose(Int32)" begin

gn = VCInt32Gen()

@testset "emits different Int32 restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Int32
    @test -1000 <= td <= 2000
    #@mcheck_values_vary td
end

end


@generator VCUIntGen begin
    start() = choose(UInt,4,420)
end

@testset "choose(UInt)" begin

gn = VCUIntGen()

@testset "emits different UInt restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == UInt
    @test 4 <= td <= 420
    #@mcheck_values_vary td
end

end


@generator VCFloat64Gen begin
    start() = choose(Float64,-4.2,32.7)
end

@testset "choose(Float64)" begin

gn = VCFloat64Gen()

@testset "emits different Float64 restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Float64
    @test -4.2 <= td <= 32.7
    #@mcheck_values_vary td
end

end


@generator VCFloat64NoMaxGen begin
    start() = choose(Float64,-4.2)
end

@testset "choose(Float64) with no max specified" begin

gn = VCFloat64NoMaxGen()

@testset "emits different Float64 greater than or equal to min" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Float64
    @test -4.2 <= td
    #@mcheck_values_vary td
end
	
end


@generator VCFloat64NoRangeGen begin
    start() = choose(Float64,-4.2)
end

@testset "choose(Float64) with no min nor max specified" begin

gn = VCFloat64NoRangeGen()

@testset "emits different Float64 with restriction" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Float64
    #@mcheck_values_vary td
end

end


@generator VCFloat64NonLiteralGen begin
    start() = choose(Float64,-2.1*2,32.0+0.7)
end

@testset "choose(Float64) using defined by non-literals" begin

gn = VCFloat64NonLiteralGen()

@testset "emits different Float64 restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Float64
    @test -4.2 <= td <= 32.7
    #@mcheck_values_vary td
end

end

@generator VCFloat64VariableGen begin
    start() = choose(Float64,x(),y())
    x() = -4.2
    y() = 32.7
end

@testset "choose(Float64) using range defined by variables" begin

gn = VCFloat64VariableGen()

@testset "emits different Float64 restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Float64
    @test -4.2 <= td <= 32.7
    #@mcheck_values_vary td
end

end


@generator VCFloat32Gen begin
    start() = choose(Float32,-4.2,32.7)
end

@testset "choose(Float32)" begin

gn = VCFloat32Gen()

@testset "emits different Float32 restricted to range" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) == Float32
    @test -4.2 <= td <= 32.7
    #@mcheck_values_vary td
end

end
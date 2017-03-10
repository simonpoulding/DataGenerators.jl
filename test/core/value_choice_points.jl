# tests value choice points, i.e. using choose(DataType) construct

# TODO to avoid repetition, would like to construct tests for types using metaprogramming
# HOWEVER, this works with Expressions constructed without interpolation, but as soon as
# interpolation is performed:
# (a) an explicit macroexpand is required before the eval
# (b) even then, either (DataGenerators.)choose is not recognised or, if instead Autotest.eval is explicitly using, then (DataGenerators.)gen is not recognised - a scoping issue/bug?
# And it does not appear to be possible to manipulate code as a string as an alternative (using parse, then eval)
#
# NOTE: For this reason, currently only the most common types are tested, and even within these, not all
# combinations of parameters are tested

@generator VCBoolGen begin # prefix VC (for Value Choice points) to avoid type name clashes
    start() = choose(Bool)
end

@generator VCIntGen begin
    start() = choose(Int,-1000,2000)
end

@generator VCIntNonLiteralGen begin
    start() = choose(Int,-10*100,2*1000)
end

@generator VCIntVariableGen begin
    start() = choose(Int,-1000,2000)
    x() = -1000
    y() = 2000
end

@generator VCIntNoMaxGen begin
    start() = choose(Int,-1000)
end

@generator VCIntNoRangeGen begin
    start() = choose(Int)
end

@generator VCInt64Gen begin
    start() = choose(Int64,-1000,2000)
end

@generator VCInt32Gen begin
    start() = choose(Int32,-1000,2000)
end

@generator VCUIntGen begin
    start() = choose(UInt,4,420)
end

@generator VCFloat64Gen begin
    start() = choose(Float64,-4.2,32.7)
end

@generator VCFloat64NoMaxGen begin
    start() = choose(Float64,-4.2)
end

@generator VCFloat64NoRangeGen begin
    start() = choose(Float64,-4.2)
end

@generator VCFloat64NonLiteralGen begin
    start() = choose(Float64,-2.1*2,32.0+0.7)
end

@generator VCFloat64VariableGen begin
    start() = choose(Float64,x(),y())
    x() = -4.2
    y() = 32.7
end

@generator VCFloat32Gen begin
    start() = choose(Float32,-4.2,32.7)
end


@testset "value choice points" begin

	@testset "choose(Bool)" begin

	    gn = VCBoolGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Bool
		    @mtest_values_vary td
		end
	
	end

	@testset "choose(Int)" begin

		gn = VCIntGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @test -1000 <= td <= 2000
		    @mtest_values_vary td
		end

	end

	@testset "choose(Int) using range defined by non-literals" begin

		gn = VCIntNonLiteralGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @test -1000 <= td <= 2000
		    @mtest_values_vary td
		end

	end

	@testset "choose(Int) using range defined by variables" begin

		gn = VCIntVariableGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @test -1000 <= td <= 2000
		    @mtest_values_vary td
		end

	end

	@testset "choose(Int) with no max specified" begin

		gn = VCIntNoMaxGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @test -1000 <= td
		    @mtest_values_vary td
		end

	end

	@testset "choose(Int) with no min nor max specified" begin

		gn = VCIntNoRangeGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @mtest_values_vary td
		end

	end

	@testset "choose(Int64)" begin

		gn = VCInt64Gen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @test -1000 <= td <= 2000
		    @mtest_values_vary td
		end

	end

	@testset "choose(Int32)" begin

		gn = VCInt32Gen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int32
		    @test -1000 <= td <= 2000
		    @mtest_values_vary td
		end

	end

	@testset "choose(UInt)" begin

		gn = VCUIntGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == UInt
		    @test 4 <= td <= 420
		    @mtest_values_vary td
		end

	end

	@testset "choose(Float64)" begin

		gn = VCFloat64Gen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Float64
		    @test -4.2 <= td <= 32.7
		    @mtest_values_vary td
		end

	end

	@testset "choose(Float64) with no max specified" begin

		gn = VCFloat64NoMaxGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Float64
		    @test -4.2 <= td
		    @mtest_values_vary td
		end
	
	end

	@testset "choose(Float64) with no min nor max specified" begin

		gn = VCFloat64NoRangeGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Float64
		    @mtest_values_vary td
		end

	end

	@testset "choose(Float64) using defined by non-literals" begin

		gn = VCFloat64NonLiteralGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Float64
		    @test -4.2 <= td <= 32.7
		    @mtest_values_vary td
		end

	end

	@testset "choose(Float64) using range defined by variables" begin

		gn = VCFloat64VariableGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Float64
		    @test -4.2 <= td <= 32.7
		    @mtest_values_vary td
		end

	end

	@testset "choose(Float32)" begin

		gn = VCFloat32Gen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Float32
		    @test -4.2 <= td <= 32.7
		    @mtest_values_vary td
		end

	end

end
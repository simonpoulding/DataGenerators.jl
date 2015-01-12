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

describe("choose(Bool)") do

	gn = VCBoolGen()

  @repeat test("emits different Boolean") do
		td = gen(gn)
		@check typeof(td) == Bool
		@mcheck_values_vary td
	end
	
end


@generator VCIntGen begin
	start() = choose(Int,-1000,2000)
end

describe("choose(Int)") do

	gn = VCIntGen()

  @repeat test("emits different Int restricted to range") do
		td = gen(gn)
		@check typeof(td) == Int
		@check -1000 <= td <= 2000
		@mcheck_values_vary td
	end

end


@generator VCIntNonLiteralGen begin
	start() = choose(Int,-10*100,2*1000)
end

describe("choose(Int) using range defined by non-literals") do

	gn = VCIntNonLiteralGen()

  @repeat test("emits different Int restricted to range") do
		td = gen(gn)
		@check typeof(td) == Int
		@check -1000 <= td <= 2000
		@mcheck_values_vary td
	end

end


@generator VCIntVariableGen begin
	start() = choose(Int,-1000,2000)
	x() = -1000
	y() = 2000
end

describe("choose(Int) using range defined by variables") do

	gn = VCIntVariableGen()

  @repeat test("emits different Int restricted to range") do
		td = gen(gn)
		@check typeof(td) == Int
		@check -1000 <= td <= 2000
		@mcheck_values_vary td
	end

end


@generator VCIntNoMaxGen begin
	start() = choose(Int,-1000)
end

describe("choose(Int) with no max specified") do

	gn = VCIntNoMaxGen()

  @repeat test("emits different Int greater than or equal to min") do
		td = gen(gn)
		@check typeof(td) == Int
		@check -1000 <= td
		@mcheck_values_vary td
	end

end


@generator VCIntNoRangeGen begin
	start() = choose(Int)
end

describe("choose(Int) with no min nor max specified") do

	gn = VCIntNoRangeGen()

  @repeat test("emits different Int without restriction") do
		td = gen(gn)
		@check typeof(td) == Int
		@mcheck_values_vary td
	end

end


@generator VCInt64Gen begin
	start() = choose(Int64,-1000,2000)
end

describe("choose(Int64)") do

	gn = VCInt64Gen()

  @repeat test("emits different Int restricted to range") do
		td = gen(gn)
		@check typeof(td) == Int
		@check -1000 <= td <= 2000
		@mcheck_values_vary td
	end

end


@generator VCInt32Gen begin
	start() = choose(Int32,-1000,2000)
end

describe("choose(Int32)") do

	gn = VCInt32Gen()

  @repeat test("emits different Int32 restricted to range") do
		td = gen(gn)
		@check typeof(td) == Int32
		@check -1000 <= td <= 2000
		@mcheck_values_vary td
	end

end


@generator VCUintGen begin
	start() = choose(Uint,4,420)
end

describe("choose(UInt)") do

	gn = VCUintGen()

  @repeat test("emits different UInt restricted to range") do
		td = gen(gn)
		@check typeof(td) == Uint
		@check 4 <= td <= 420
		@mcheck_values_vary td
	end

end


@generator VCFloat64Gen begin
	start() = choose(Float64,-4.2,32.7)
end

describe("choose(Float64)") do

	gn = VCFloat64Gen()

  @repeat test("emits different Float64 restricted to range") do
		td = gen(gn)
		@check typeof(td) == Float64
		@check -4.2 <= td <= 32.7
		@mcheck_values_vary td
	end

end


@generator VCFloat64NoMaxGen begin
	start() = choose(Float64,-4.2)
end

describe("choose(Float64) with no max specified") do

	gn = VCFloat64NoMaxGen()

  @repeat test("emits different Float64 greater than or equal to min") do
		td = gen(gn)
		@check typeof(td) == Float64
		@check -4.2 <= td
		@mcheck_values_vary td
	end
	
end


@generator VCFloat64NoRangeGen begin
	start() = choose(Float64,-4.2)
end

describe("choose(Float64) with no min nor max specified") do

	gn = VCFloat64NoRangeGen()

  @repeat test("emits different Float64 with restriction") do
		td = gen(gn)
		@check typeof(td) == Float64
		@mcheck_values_vary td
	end

end


@generator VCFloat64NonLiteralGen begin
	start() = choose(Float64,-2.1*2,32.0+0.7)
end

describe("choose(Float64) using defined by non-literals") do

	gn = VCFloat64NonLiteralGen()

  @repeat test("emits different Float64 restricted to range") do
		td = gen(gn)
		@check typeof(td) == Float64
		@check -4.2 <= td <= 32.7
		@mcheck_values_vary td
	end

end

@generator VCFloat64VariableGen begin
	start() = choose(Float64,x(),y())
	x() = -4.2
	y() = 32.7
end

describe("choose(Float64) using range defined by variables") do

	gn = VCFloat64VariableGen()

  @repeat test("emits different Float64 restricted to range") do
		td = gen(gn)
		@check typeof(td) == Float64
		@check -4.2 <= td <= 32.7
		@mcheck_values_vary td
	end

end


@generator VCFloat32Gen begin
	start() = choose(Float32,-4.2,32.7)
end

describe("choose(Float32)") do

	gn = VCFloat32Gen()

  @repeat test("emits different Float32 restricted to range") do
		td = gen(gn)
		@check typeof(td) == Float32
		@check -4.2 <= td <= 32.7
		@mcheck_values_vary td
	end

end
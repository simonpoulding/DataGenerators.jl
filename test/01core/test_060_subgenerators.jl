# tests sub-generators

using GodelTest


# generator and sub-generators

@generator SGBoolGen begin # prefix SG (for Sub-Generators) to avoid type name clashes
	start() = choose(Bool)
end

@generator SGIntGen begin
	start() = choose(Int,5,9)
end

@generator SGMain1SGGen(intGen) begin
	start() = intGen()
end

# important to have test for only one sub-generator in order to ensure correct handling of constructors
describe("generator with one sub-generator") do

	ign = SGIntGen()
	gn = SGMain1SGGen(ign)

	@repeat test("emits an integer between 5 and 9") do
		td = gen(gn)
		@check typeof(td) == Int
		@check 5 <= td <= 9
		@mcheck_values_vary td
	end

end

@generator SGMain2SGGen(boolGen, intGen) begin
	start() = map(i->boolGen(), 1:intGen())
end

describe("generator with two sub-generators") do

	bgn = SGBoolGen()
	ign = SGIntGen()
	gn = SGMain2SGGen(bgn, ign)

  @repeat test("emits arrays of different Bool of different lengths between 5 and 9") do
		td = gen(gn)
		@check typeof(td) == Vector{Bool}
		@check 5 <= length(td) <= 9
		@mcheck_that_sometimes minimum(td) != maximum(td) # different Bool values
		@mcheck_values_vary length(td) # different lengths
	end
	
end


@generator SGNoParamFormGen(intGen) begin
	start() = intGen
end

describe("sub-generator called using no-params short form") do

	ign = SGIntGen()
	gn = SGNoParamFormGen(ign)

	@repeat test("emits integers between 5 and 9") do
		td = gen(gn)
		@check typeof(td) == Int
		@check 5 <= td <= 9
		@mcheck_values_vary td
	end

end

@generator SGRepsGen(intGen) begin
	start() = mult(intGen)
end

describe("sub-generator as a sequence choice point") do

	ign = SGIntGen()
	gn = SGRepsGen(ign)

	@repeat test("emits array of integers between 5 and 9") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check all(5 .<= td .<= 9)
		@mcheck_values_vary length(td)
	end

end
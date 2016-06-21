# tests sub-generators

# generator and sub-generators

@generator SGBoolGen begin # prefix SG (for Sub-Generators) to avoid type name clashes
    start() = choose(Bool)
end

@generator SGIntGen begin
    start() = choose(Int,5,9)
end

@generator SGMain1SGGen(intGen) begin
    start() = choose(intGen)
end

# important to have test for only one sub-generator in order to ensure correct handling of constructors
@testset "generator with one sub-generator" begin

ign = SGIntGen()
gn = SGMain1SGGen(ign)

@testset repeats=NumReps "emits an integer between 5 and 9" begin
    td = choose(gn)
    @test typeof(td) == Int
    @test 5 <= td <= 9
    @mcheck_values_vary td
end

end

@generator SGMain2SGGen(boolGen, intGen) begin
    start() = map(i->choose(boolGen), 1:choose(intGen))
end

@testset "generator with two sub-generators" begin

bgn = SGBoolGen()
ign = SGIntGen()
gn = SGMain2SGGen(bgn, ign)

@testset repeats=NumReps "emits arrays of different Bool of different lengths between 5 and 9" begin
    td = choose(gn)
    @test typeof(td) == Vector{Bool}
    @test 5 <= length(td) <= 9
    @mcheck_that_sometimes minimum(td) != maximum(td) # different Bool values
    @mcheck_values_vary length(td) # different lengths
end
	
end


@generator SGNoParamFormGen(intGen) begin
    start() = choose(intGen)
end

@testset "sub-generator called using no-params short form" begin

ign = SGIntGen()
gn = SGNoParamFormGen(ign)

@testset repeats=NumReps "emits integers between 5 and 9" begin
    td = choose(gn)
    @test typeof(td) == Int
    @test 5 <= td <= 9
    @mcheck_values_vary td
end

end

@generator SGRepsGen(intGen) begin
    start() = mult(choose(intGen))
end

@testset "sub-generator as a sequence choice point" begin

ign = SGIntGen()
gn = SGRepsGen(ign)

@testset repeats=NumReps "emits array of integers between 5 and 9" begin
    td = choose(gn)
    @test typeof(td) <: Array
    @test all(5 .<= td .<= 9)
    @mcheck_values_vary length(td)
end

end
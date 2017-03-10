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

@generator SGMain2SGGen(boolGen, intGen) begin
    start() = map(i->choose(boolGen), 1:choose(intGen))
end

@generator SGNoParamFormGen(intGen) begin
    start() = choose(intGen)
end

@generator SGRepsGen(intGen) begin
    start() = mult(choose(intGen))
end


@testset "subgenerators" begin

	# important to have test for only one sub-generator in order to ensure correct handling of constructors
	@testset "generator with one sub-generator" begin

		ign = SGIntGen()
		gn = SGMain1SGGen(ign)

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @test 5 <= td <= 9
		    @mtest_values_vary td
		end

	end

	@testset "generator with two sub-generators" begin

		bgn = SGBoolGen()
		ign = SGIntGen()
		gn = SGMain2SGGen(bgn, ign)

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Vector{Bool}
		    @test 5 <= length(td) <= 9
		    @mtest_that_sometimes minimum(td) != maximum(td) # different Bool values
		    @mtest_values_vary length(td) # different lengths
		end
	
	end

	@testset "sub-generator called using no-params short form" begin

		ign = SGIntGen()
		gn = SGNoParamFormGen(ign)

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == Int
		    @test 5 <= td <= 9
		    @mtest_values_vary td
		end

	end

	@testset "sub-generator as a sequence choice point" begin

		ign = SGIntGen()
		gn = SGRepsGen(ign)

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test all(5 .<= td .<= 9)
		    @mtest_values_vary length(td)
		end

	end

end
@generator NMCExampleGen begin 
    start() = mult(a) 
    a() = choose(Int, -2, 3)
    a() = choose(Float64, 9.1, 9.2)
    a() = choose(Bool)
end

@generator NMCXListGen begin
	start() = "x" * (choose(Bool) ? start() : "")
end

@generator NMCXYListGen begin
	start() = xy() * (choose(Bool) ? start() : "")
	xy() = "x"
	xy() = "y"
end

@testset "NMCS choice model" begin

	@testset "constructor (one level)" begin

	    gn = NMCExampleGen()
		
		setsamplerchoicemodel!(gn)
		setnmcschoicemodel!(gn, x->1.0)
		cm = choicemodel(gn)
		
	    @test typeof(cm) == DataGenerators.NMCSChoiceModel

		setnmcschoicemodel!(gn, x->1.0)
		cm2 = choicemodel(gn)

	    @test typeof(cm2) == DataGenerators.NMCSChoiceModel
		
	end
	

	@testset "set/get parameters and ranges" begin

	    gn = NMCExampleGen()
	
		setsamplerchoicemodel!(gn)
		scm = deepcopy(choicemodel(gn))
		setnmcschoicemodel!(gn, x->1.0)
		cm = choicemodel(gn)

		@testset "paramranges" begin
		    ranges = paramranges(cm)
		    @test typeof(ranges) <: Vector{Tuple{Float64,Float64}}
		    @test ranges == paramranges(scm)
		end

		@testset "getparams" begin
		    params = getparams(cm)
		    @test typeof(params) <: Vector{Float64}
		    @test params == getparams(scm)
		end

		@testset "setparams" begin
		    newparams = [0.7, 0.4, 0.7, 0.4, 0.7]
			setparams!(scm, newparams)
		    setparams!(cm, newparams)
		    @test getparams(cm) == getparams(scm)
		end

	end
	
	@testset "always successful with sufficient samplesize" begin
	
		gn = NMCXListGen()
		setsamplerchoicemodel!(gn)
		fitness(x) = abs(length(x)-20)
		setnmcschoicemodel!(gn, fitness, 10)
	
		@mtestset "length is always 20" begin
			y = choose(gn)
			@test length(y) == 20
		end
	
	end
	
	@testset "sometimes unsuccessful with insufficient samplesize" begin
	
		gn = NMCXListGen()
		setsamplerchoicemodel!(gn)
		fitness(x) = abs(length(x)-20)
		setnmcschoicemodel!(gn, fitness, 1)
	
		@mtestset "length is sometimes not 20" begin
			y = choose(gn)
			@mtest_that_sometimes length(y) != 20
		end
	
	end

	@testset "sometimes successful with inbetween samplesize" begin
	
		gn = NMCXListGen()
		setsamplerchoicemodel!(gn)
		fitness(x) = abs(length(x)-20)
		setnmcschoicemodel!(gn, fitness, 2)
	
		@mtestset "length is sometimes 20" begin
			y = choose(gn)
			@mtest_that_sometimes length(y) == 20
		end
	
	end

	@testset "state is reset on each choice" begin
	
		gn = NMCXYListGen()
		setsamplerchoicemodel!(gn)
		fitness(x) = abs(length(x)-20)
		setnmcschoicemodel!(gn, fitness, 10)
	
		@mtestset "length is always 40 but values are different" begin
			y = choose(gn)
			@test length(y) == 20
			@mtest_values_vary y
		end
	
	end

end
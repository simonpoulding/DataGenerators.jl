@testset "adjust parameters to support sampler" begin

	cc = dummyChoiceContext()
	
	@testset "constructor, getparams, numparams, paramranges, setparams" begin

		subsA = DataGenerators.UniformSampler([7.1,9.2])
		s = DataGenerators.AdjustParametersToSupportSampler(subsA)
	
	    @testset "numparams and paramranges" begin
			@test DataGenerators.numparams(s) == 0
			prs = DataGenerators.paramranges(s)
	        @test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
			@test prs == Tuple{Float64,Float64}[]
	    end

	    @testset "default params" begin			
			@test DataGenerators.getparams(s) == Float64[]
	    end

		@testset "setparams"  begin
			DataGenerators.setparams(s, Float64[])
			@test_throws ErrorException DataGenerators.setparams(s, [0.0])
		end

		@testset "validates subsampler to supported types" begin
			@test_throws ErrorException DataGenerators.AdjustParametersToSupportSampler(DataGenerators.GeometricSampler())
		end

	end

	@testset "sampling" begin

		subsA = DataGenerators.DiscreteUniformSampler([-1000.0, 214455.0])
		s = DataGenerators.AdjustParametersToSupportSampler(subsA)

		@mtestset "support is applied" reps=Main.REPS alpha=Main.ALPHA for cpsupport in [(188, 199), (-4, -4),]
			# note: includes case where lower bound = upper bound
			x, trace = DataGenerators.sample(s, cpsupport, cc)
			@test cpsupport[1] <= x <= cpsupport[2]
			@mtest_distributed_as DiscreteUniform(cpsupport[1],cpsupport[2]) x 
		end
		
	end
	
	@testset "estimateparams" begin

		subsparams = [9.3, 15.8]
		subs1A = DataGenerators.UniformSampler(subsparams)
		s1 =DataGenerators.AdjustParametersToSupportSampler(subs1A)

		othersubsparams = [-55.1, -4.2]
		subs2A = DataGenerators.UniformSampler(othersubsparams)
		s2 =DataGenerators.AdjustParametersToSupportSampler(subs2A)

		traces = map(1:100) do i
			x, trace = DataGenerators.sample(s1, (0,1), cc)
			trace
		end

		estimateparams(s2, traces)
			
		@test DataGenerators.getparams(s2) == Float64[]
		@test DataGenerators.getparams(subs2A) == othersubsparams
		# because no parameters of its own to estimate

	end
	
end


@testset "align minimum support sampler" begin

	cc = dummyChoiceContext()
	
	@testset "constructor, getparams, numparams, paramranges, setparams" begin

		subsA = DataGenerators.GeometricSampler()
		s = DataGenerators.AlignMinimumSupportSampler(subsA)
	
	    @testset "numparams and paramranges" begin
			@test DataGenerators.numparams(s) == DataGenerators.numparams(subsA)
			@test DataGenerators.paramranges(s) == DataGenerators.paramranges(subsA)
	    end

	    @testset "default params" begin			
			@test DataGenerators.getparams(s) == DataGenerators.getparams(subsA)
	    end

		@testset "setparams"  begin
			DataGenerators.setparams(s, [0.4])
			@test DataGenerators.getparams(subsA) == [0.4]
			@test DataGenerators.getparams(s) == [0.4]
		end

	end

	@testset "sampling" begin
	
		subsA = DataGenerators.GeometricSampler([0.3])
		s = DataGenerators.AlignMinimumSupportSampler(subsA)

		@mtestset "support is applied for support $cpsupport" reps=Main.REPS alpha=Main.ALPHA for cpsupport in [(17, typemax(Int)), (-4, -4), (0, 10),]
			x, trace = DataGenerators.sample(s, cpsupport, cc)
			@test cpsupport[1] <= x # this sampler does not guarantee x <= cpsupport[2]
			@mtest_distributed_as Geometric(0.3) x-cpsupport[1]
		end
		
	end
	
	@testset "estimateparams" begin

 			subs1A = DataGenerators.GeometricSampler()
			s1 = DataGenerators.AlignMinimumSupportSampler(subs1A)
			params = [0.6]
			DataGenerators.setparams(s1, params)

			subs2A = DataGenerators.GeometricSampler()
			s2 = DataGenerators.AlignMinimumSupportSampler(subs2A)
			otherparams = [0.3]
			DataGenerators.setparams(s2, otherparams)

			traces = map(1:100) do i
				cpsupport =[rand(-100:100) for j in 1:2] 
				x, trace = DataGenerators.sample(s1, (minimum(cpsupport),maximum(cpsupport)), cc)
				trace
			end
			# note: varying support in traces - to check if re-estimation is based on underlying sample from distribution
			# and not the adjustment

			estimateparams(s2, traces)

			@mtestset "consistent with geometric" reps=Main.REPS alpha=Main.ALPHA begin
				x, trace = DataGenerators.sample(s2, (0,1), cc)
				@mtest_distributed_as Geometric(params[1]) x
			end

	end
	
end


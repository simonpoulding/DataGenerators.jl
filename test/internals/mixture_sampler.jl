@testset "mixture sampler" begin

	cc = dummyChoiceContext()
	
	@testset "getparams, numparams, paramranges, sample" begin

		subsA = DataGenerators.BernoulliSampler()
		subsB = DataGenerators.DiscreteUniformSampler([7.0,9.0])
		s = DataGenerators.MixtureSampler(subsA,subsB)
	
	    @testset "numparams and paramranges" begin
			@test DataGenerators.numparams(s) == 2 + DataGenerators.numparams(subsA) + DataGenerators.numparams(subsB)
			prs = DataGenerators.paramranges(s)
	        @test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
			@test prs == [(0.0,1.0); (0.0,1.0); DataGenerators.paramranges(subsA); DataGenerators.paramranges(subsB)]
	    end

	    @testset "default params" begin			
			@test DataGenerators.getparams(s) == [0.5; 0.5; DataGenerators.getparams(subsA); DataGenerators.getparams(subsB)]
	    end

	    @mtestset "default sampling" reps=Main.REPS alpha=Main.ALPHA begin
	        x, trace = DataGenerators.sample(s, (0,1), cc)
	        @test typeof(x) <: Int
 			@mtest_values_are [0,1,7,8,9] x
			if x <= 1
				@mtest_distributed_as Bernoulli(0.5) x
			else
				@mtest_distributed_as DiscreteUniform(7,9) x
			end
	    end
					
	end

	@testset "setparams" begin

		subsA = DataGenerators.BernoulliSampler()
		subsB = DataGenerators.DiscreteUniformSampler()
		subsC = DataGenerators.GeometricSampler()
		s = DataGenerators.MixtureSampler(subsA,subsB,subsC)
		prs = DataGenerators.paramranges(s)
		midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

		@testset "parameters of subsamplers" begin
		
			params = [0.1, 0.2, 0.7, 0.4, 1.0, 6.0, 0.3]
			DataGenerators.setparams(s, params)
			@test DataGenerators.getparams(subsA) == [0.4]
			@test DataGenerators.getparams(subsB) == [1.0, 6.0]
			@test DataGenerators.getparams(subsC) == [0.3]

			@mtestset "consistent with mixture" reps=Main.REPS alpha=Main.ALPHA begin
            	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as MixtureModel([Bernoulli(0.4),DiscreteUniform(1,6),Geometric(0.3)],[0.1,0.2,0.7]) x
			end

		end

		@testset "boundary values choice params $choiceparams" for choiceparams in [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0],]

            DataGenerators.setparams(s, [choiceparams; [0.4, 1.0, 6.0, 0.3]])

			@mtestset "consistent with mixture" reps=Main.REPS alpha=Main.ALPHA begin
            	x, trace = DataGenerators.sample(s, (0,1), cc)
				if choiceparams[1] == 1.0
					@mtest_distributed_as Bernoulli(0.4) x
				elseif choiceparams[2] == 1.0
					@mtest_distributed_as DiscreteUniform(1,6) x
				elseif choiceparams[3] == 1.0
					@mtest_distributed_as Geometric(0.3) x
				end
			end
			
		end			

		@testset "range check exception choice params $pidx bound $bidx" for pidx in 1:3, bidx in 1:2
			choiceparams = [0.5, 0.4, 0.1]
            choiceparams[pidx] = bidx == 1 ? prevfloat(prs[pidx][bidx]) : nextfloat(prs[pidx][bidx])
            @test_throws ErrorException DataGenerators.setparams(s, [choiceparams, [0.4, 1.0, 6.0, 0.3]])
		end

	    @testset "wrong number of parameters" begin
	        @test_throws ErrorException DataGenerators.setparams(s, midparams[1:end-1])
	        @test_throws ErrorException DataGenerators.setparams(s, [midparams; 0.5])
	    end

	end

	@testset "estimateparams" begin

		subs1A = DataGenerators.BernoulliSampler()
		subs1B = DataGenerators.DiscreteUniformSampler()
		s1 = DataGenerators.MixtureSampler(subs1A,subs1B)

		@testset "from parameters $params" for params in [[0.6, 0.4, 0.7, 10.0, 13.0],]

			DataGenerators.setparams(s1, params)

			subs2A = DataGenerators.BernoulliSampler()
			subs2B = DataGenerators.DiscreteUniformSampler()
			s2 = DataGenerators.MixtureSampler(subs2A,subs2B)
			otherparams = [0.3, 0.7, 0.3, -40.0, -27.0]
			DataGenerators.setparams(s2, otherparams)

			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1), cc)
				trace
			end
			estimateparams(s2, traces)

			@mtestset "consistent with mixture" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as MixtureModel([Bernoulli(params[3]),DiscreteUniform(Int(params[4]),Int(params[5]))],params[1:2]) x 
			end
		
		end
	
	    @testset "too few traces" begin
	
	        params = [0.2, 0.8, 0.5, 1.0, 6.0]
			DataGenerators.setparams(s1, params)

			subs2A = DataGenerators.BernoulliSampler()
			subs2B = DataGenerators.DiscreteUniformSampler()
			s2 = DataGenerators.MixtureSampler(subs2A,subs2B)
			otherparams = [0.3, 0.7, 0.3, -40.0, -27.0]
			DataGenerators.setparams(s2, otherparams)

	        traces = map(1:0) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams(s2, traces)

			@mtestset "consistent with mixture" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as MixtureModel([Bernoulli(otherparams[3]),DiscreteUniform(Int(otherparams[4]),Int(otherparams[5]))],otherparams[1:2]) x 
			end

	    end
	
	end
	
end

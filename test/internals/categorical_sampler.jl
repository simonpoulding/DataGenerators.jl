@testset "categorical sampler" begin

	cc = dummyChoiceContext()

	@testset "getparams, numparams, paramranges, sample" begin

		@testset "using default construction" begin

			s = DataGenerators.CategoricalSampler(4)

			@testset "numparams and paramranges" begin
			    @test DataGenerators.numparams(s) == 4
			    prs = DataGenerators.paramranges(s)
			    @test typeof(prs) <: Vector{Tuple{Float64,Float64}}
			    @test prs == fill((0.0,1.0), DataGenerators.numparams(s))
			end
	
			@testset "default params" begin
			    @test DataGenerators.getparams(s) == [0.25, 0.25, 0.25, 0.25]
			end
	
			@mtestset "default sampling" reps=Main.REPS alpha=Main.ALPHA begin
			    x, trace = DataGenerators.sample(s, (0,1), cc)
			    @test typeof(x) <: Int
			    @mtest_values_are [1,2,3,4] x
		        @mtest_distributed_as Categorical([0.25,0.25,0.25,0.25]) x 
			end

		end

		@testset "non-default construction" begin

			s = DataGenerators.CategoricalSampler(5, [0.3,0.2,0.1,0.2,0.2])
		
			@testset "constructor with params" begin

			    @test getparams(s) == [0.3,0.2,0.1,0.2,0.2]

			    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
	            	x, trace = DataGenerators.sample(s, (0,1), cc)
			        @mtest_distributed_as Categorical([0.3,0.2,0.1,0.2,0.2]) x
			    end

			end

		end
		
	end
	
	@testset "setparams" begin
	
		s = DataGenerators.CategoricalSampler(4)
		prs = DataGenerators.paramranges(s)
		midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

		@testset "valid parameters $params" for params in [[0.1,0.2,0.3,0.4], [0.4,0.1,0.1,0.4], [0.3,0.2,0.3,0.2],]

		    DataGenerators.setparams(s, params)

		    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Categorical(params) x
			end

		end

		@testset "boundary values for parameter index $pidx" for pidx in 1:length(prs)

		    pr = prs[pidx]
		    params = copy(midparams)

			@testset "bound index $bidx" for bidx in 1:2

		        params[pidx] = pr[bidx] 
		        DataGenerators.setparams(s, params)
	
			    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
		        	x, trace = DataGenerators.sample(s, (0,1), cc)
			        @mtest_distributed_as  Categorical(params./sum(params)) x
				end

				@testset "range check exception" begin
		            params[pidx] = bidx == 1 ? prevfloat(pr[bidx]) : nextfloat(pr[bidx])
		            @test_throws ErrorException DataGenerators.setparams(s, params)
				end
	
			end

		end
	
		@testset "setparams normalises weights" begin

		    DataGenerators.setparams(s, [0.4, 0.6, 0.7, 0.3])
		    @test getparams(s) == [0.2, 0.3, 0.35, 0.15]

		    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Categorical([0.2,0.3,0.35,0.15]) x 
			end

		end
	
		@testset "setparams adjusts when all weights are zero" begin
	
		    DataGenerators.setparams(s, [0.0, 0.0, 0.0, 0.0])
		    @test getparams(s) == [0.25, 0.25, 0.25, 0.25]
		
		    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Categorical([0.25,0.25,0.25,0.25]) x 
			end
		
		end

		@testset "setparams with wrong number of parameters" begin
		    @test_throws ErrorException DataGenerators.setparams(s, midparams[1:end-1])
		    @test_throws ErrorException DataGenerators.setparams(s, [midparams; 0.5])
		end
		
	end
	
	@testset "estimateparams" begin
		
		otherparams = [0.35, 0.15, 0.1, 0.25, 0.15]
		
		@testset "equal bounds" begin
	
		    params = [0.2, 0.2, 0.2, 0.2, 0.2]
		    s1 = DataGenerators.CategoricalSampler(5, params)
		    s2 = DataGenerators.CategoricalSampler(5, otherparams)	
		    traces = map(1:100) do i
		        x, trace = DataGenerators.sample(s1, (0,1), cc)
		        trace
		    end
		    estimateparams(s2, traces)

		    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as Categorical(params) x
			end

		end

		@testset "last category never sampled" begin
	
		    params = [0.3, 0.4, 0.2, 0.1, 0.0]
		    s1 = DataGenerators.CategoricalSampler(5, params)
		    s2 = DataGenerators.CategoricalSampler(5, otherparams)	
		    traces = map(1:100) do i
		        x, trace = DataGenerators.sample(s1, (0,1), cc)
		        trace
		    end
		    estimateparams(s2, traces)

		    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as Categorical(params) x
			end

		end

		@testset "too few traces" begin
	
		    params = [0.1, 0.2, 0.4, 0.2, 0.1]
		    s1 = DataGenerators.CategoricalSampler(5, params)
		    s2 = DataGenerators.CategoricalSampler(5, otherparams)	
		    traces = map(1:0) do i
		        x, trace = DataGenerators.sample(s1, (0,1), cc)
		        trace
		    end
		    estimateparams(s2, traces)

		    @mtestset "consistent with categorical" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as Categorical(otherparams) x
			end

		end
		
	end
		
end

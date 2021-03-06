@testset "Bernoulli sampler" begin

	cc = dummyChoiceContext()
	
	@testset "getparams, numparams, paramranges, sample" begin

		@testset "using default construction" begin
		
		    s = DataGenerators.BernoulliSampler()

		    @testset "numparams and paramranges" begin
		        @test DataGenerators.numparams(s) == 1
		        prs = DataGenerators.paramranges(s)
		        @test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
		        @test prs == [(0.0,1.0)]
		    end
	
		    @testset "default params" begin			
		        @test DataGenerators.getparams(s) == [0.5]
		    end

		    @mtestset "default sampling" reps=Main.REPS alpha=Main.ALPHA begin
		        x, trace = DataGenerators.sample(s, (0,1), cc)
		        @test typeof(x) <: Int
		        @mtest_values_are [0,1] x
				@mtest_distributed_as Bernoulli(0.5) x
		    end
		
		end
	
		@testset "using non-default construction" begin

		    s = DataGenerators.BernoulliSampler([0.3])
		    @test DataGenerators.getparams(s) == [0.3]

		    @mtestset "consistent with Bernoulli" reps=Main.REPS alpha=Main.ALPHA begin
		    	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Bernoulli(0.3) x
		    end

		end
		
	end

	@testset "setparams" begin

	    s = DataGenerators.BernoulliSampler()
	    prs = DataGenerators.paramranges(s)
	    midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

	    @testset "valid parameters $params" for params in [[0.8], [0.5], [0.3],]
	 
	        DataGenerators.setparams!(s, params)

			@mtestset "consistent with Bernoulli" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Bernoulli(params[1]) x
			end

	    end
		
	    @testset "boundary values for parameter index $pidx" for pidx in 1:length(prs)
	
	        pr = prs[pidx]
	        params = copy(midparams)

			@testset "bound index $bidx" for bidx in 1:2
		
	            params[pidx] = pr[bidx] 
	            DataGenerators.setparams!(s, params)
			
				@mtestset "consistent with Bernoulli" reps=Main.REPS alpha=Main.ALPHA begin
	            	x, trace = DataGenerators.sample(s, (0,1), cc)
			        @mtest_distributed_as Bernoulli(params[1]) x
				end
	
				@testset "range check exception" begin
		            params[pidx] = bidx == 1 ? prevfloat(pr[bidx]) : nextfloat(pr[bidx])
		            @test_throws ErrorException DataGenerators.setparams!(s, params)
				end
			
			end

	    end
		
	    @testset "wrong number of parameters" begin
		
	        @test_throws ErrorException DataGenerators.setparams!(s, midparams[1:end-1])
	        @test_throws ErrorException DataGenerators.setparams!(s, [midparams; 0.5])
			
	    end

	end

	@testset "estimateparams" begin

	    otherparams = [0.5]

	    @testset "from parameters $params" for params in [[0.2], [0.7], [0.0], [1.0],]
	
	        s1 = DataGenerators.BernoulliSampler(params)
	        s2 = DataGenerators.BernoulliSampler(otherparams)	
	        traces = map(1:100) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams!(s2, traces)

			@mtestset "consistent with Bernoulli" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as Bernoulli(params[1]) x
			end

	    end

	    @testset "too few traces" begin
	
	        params = [0.2]
	        s1 = DataGenerators.BernoulliSampler(params)
	        s2 = DataGenerators.BernoulliSampler(otherparams)	
	        traces = map(1:0) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams!(s2, traces)

			@mtestset "consistent with Bernoulli" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as Bernoulli(otherparams[1]) x
			end

	    end

	end

end

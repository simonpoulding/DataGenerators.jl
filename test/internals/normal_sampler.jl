@testset "normal sampler" begin

	cc = dummyChoiceContext()
	
	@testset "getparams, numparams, paramranges, sample" begin

		@testset "using default construction" begin
		
		    s = DataGenerators.NormalSampler()

		    @testset "numparams and paramranges" begin
		        @test DataGenerators.numparams(s) == 2
		        prs = DataGenerators.paramranges(s)
		        @test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
		        @test prs == [(-realmax(Float64), realmax(Float64)), (0.0, realmax(Float64))]
			end
	
		    @testset "default params" begin
		        @test DataGenerators.getparams(s) == [0.0, 1.0]
		    end

		    @mtestset "default sampling" reps=Main.REPS alpha=Main.ALPHA begin
		        x, trace = DataGenerators.sample(s, (0,1), cc)
		        @test typeof(x) <: Float64
				@mtest_that_sometimes x < -1.0
				@mtest_that_sometimes -1.0 <= x < 0.0
				@mtest_that_sometimes 0.0 < x <= 1.0
				@mtest_that_sometimes 1.0 < x
		        @mtest_distributed_as Normal(0.0,1.0) x 
			end
		
		end
	
		@testset "using non-default construction" begin

		    s = DataGenerators.NormalSampler([-949.88, 123.4])
		    @test DataGenerators.getparams(s) == [-949.88, 123.4]

		    @mtestset "consistent with normal" reps=Main.REPS alpha=Main.ALPHA begin
		    	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Normal(-949.88,123.4) x 
		    end

		end
		
	end

	@testset "setparams" begin

	    s = DataGenerators.NormalSampler()
	    prs = DataGenerators.paramranges(s)
	    midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

	    @testset "valid parameters $params" for params in [[0.8, 19.3], [87.4, 0.0],]
		# note special case of sigma = 0

	        DataGenerators.setparams(s, params)

			@mtestset "consistent with normal" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
				mu = params[1]
				sigma = params[2] == 0.0 ? eps(params[2]) : params[2]
		        @mtest_distributed_as Normal(mu,sigma) x 
			end

	    end

	    @testset "boundary values for parameter index $pidx" for pidx in 1:length(prs)

	        pr = prs[pidx]
	        params = copy(midparams)

			@testset "bound index $bidx" for bidx in 1:2

	            params[pidx] = pr[bidx]
	            DataGenerators.setparams(s, params)

				@mtestset "consistent with normal" reps=Main.REPS alpha=Main.ALPHA begin
	            	x, trace = DataGenerators.sample(s, (0,1), cc)
					mu = params[1]
					sigma = params[2] == 0.0 ? eps(params[2]) : params[2]
			        @mtest_distributed_as Normal(mu,sigma) x 
				end

				@testset "range check exception" begin
		            params[pidx] = bidx == 1 ? prevfloat(pr[bidx]) : nextfloat(pr[bidx])
		            @test_throws ErrorException DataGenerators.setparams(s, params)
				end

			end

	    end

	    @testset "wrong number of parameters" begin

	        @test_throws ErrorException DataGenerators.setparams(s, midparams[1:end-1])
	        @test_throws ErrorException DataGenerators.setparams(s, [midparams; 0.5])

	    end

	end

	@testset "estimateparams" begin

	    s = DataGenerators.NormalSampler()
	    prs = DataGenerators.paramranges(s)
	    otherparams = [155.6, 13.7]

	    @testset "from parameters $params" for params in [[-56.0, 18.9], [3.44, 0.0],]
		# note special case of sigma = 0

	        s1 = DataGenerators.NormalSampler(params)
	        s2 = DataGenerators.NormalSampler(otherparams)
	        traces = map(1:100) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams(s2, traces)

			@mtestset "consistent with normal" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
				if params[2] > 0.0
					@mtest_distributed_as Normal(params[1],params[2]) x 
				else
					@test isapprox(x, params[1])
					# necessary since above distributed_as fails when sigma=0.0 owing to rounding errors 
				end
			end

	    end

	    @testset "too few traces" begin

	        params = [21.0, 0.7]
	        s1 = DataGenerators.NormalSampler(params)
	        s2 = DataGenerators.NormalSampler(otherparams)
	        traces = map(1:1) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end

			@mtestset "consistent with normal" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as Normal(otherparams[1],otherparams[2]) x 
			end

	    end

	end

end
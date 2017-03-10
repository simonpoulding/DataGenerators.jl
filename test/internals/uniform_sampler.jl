@testset "uniform sampler" begin

	cc = dummyChoiceContext()

	@testset "getparams, numparams, paramranges, sample" begin

		@testset "using default construction" begin
		
			s = DataGenerators.UniformSampler()

			@testset "numparams and paramranges" begin
				@test DataGenerators.numparams(s) == 2
				prs = DataGenerators.paramranges(s)
				@test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
				@test prs == fill((-realmax(Float64), realmax(Float64)), 2)
			end
	
			@testset "default params" begin
				@test DataGenerators.getparams(s) == [-1.0, 1.0]
			end
	
			@mtestset "default sampling" reps=Main.REPS alpha=Main.ALPHA begin
				x, trace = DataGenerators.sample(s, (0,1), cc)
				@test typeof(x) <: Float64
				@test -1.0 <= x <= 1.0
		        @mtest_distributed_as Uniform(-1.0,1.0) x 
			end
	
		end
		
	
		@testset "non-default construction" begin

			s = DataGenerators.UniformSampler([-100.7,129.3762])
	
			@testset "constructor with params" begin
		
				@test DataGenerators.getparams(s) == [-100.7,129.3762]

				@mtestset "is consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
					x, trace = DataGenerators.sample(s, (0,1), cc)
			        @mtest_distributed_as Uniform(-100.7,129.3762) x
				end
			
			end
		
		end
	
	end
	
	
	@testset "setparams" begin

	    s = DataGenerators.UniformSampler()
	    prs = DataGenerators.paramranges(s)
	    midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

	    @testset "valid parameters $params" for params in [[8.2,50.78], [-3113.10, -228.99],  [-6.198, 6.23],]

	        DataGenerators.setparams(s, params)

			@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Uniform(params[1],params[2]) x 
			end

	    end

		@testset "setparams adjusts order of parameters" begin

			DataGenerators.setparams(s, [50.77,8.3])
			@test DataGenerators.getparams(s) == [8.3,50.77]

			@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Uniform(8.3,50.77) x 
			end

		end

		@testset "handles full Float64 range" begin
			params = [-realmax(Float64), realmax(Float64)]
			DataGenerators.setparams(s, params)

			@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Uniform(-realmax(Float64),realmax(Float64)) x 
			end

		end

	    @testset "boundary values for parameter index $pidx" for pidx in 1:length(prs)

	        pr = prs[pidx]
	        params = copy(midparams)

			@testset "bound index $bidx" for bidx in 1:2

	            params[pidx] = pr[bidx] 
		        DataGenerators.setparams(s, params)
				
				@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
		        	x, trace = DataGenerators.sample(s, (0,1), cc)
					sortedparams = sort(params)
			        @mtest_distributed_as Uniform(sortedparams[1],sortedparams[2]) x
				end
				
				@testset "range check exception" begin
		            params[pidx] = bidx == 1 ? prevfloat(pr[bidx]) : nextfloat(pr[bidx])
		            @test_throws ErrorException DataGenerators.setparams(s, params)
				end

			end

	    end

		@testset "lower bound equals upper bound" begin

			DataGenerators.setparams(s, [0.712, 0.712])
			
			@test DataGenerators.getparams(s) == [0.712, 0.712]

			@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
				@test x == 0.712
			end

		end

		@testset "samples boundaries of support" begin
		
			DataGenerators.setparams(s, [87.23, nextfloat(nextfloat(87.23))])
			
			@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
				@mtest_values_are [87.23,nextfloat(87.23),nextfloat(nextfloat(87.23))] x 
			end

		end
		
	    @testset "wrong number of parameters" begin
	        @test_throws ErrorException DataGenerators.setparams(s, midparams[1:end-1])
	        @test_throws ErrorException DataGenerators.setparams(s, [midparams; 0.5])
	    end

	end
	
	
	@testset "estimateparams" begin

	    s = DataGenerators.UniformSampler()
	    prs = DataGenerators.paramranges(s)
	   	otherparams = [-42.9, 42.2]

	    @testset "from parameters $params" for params in [[20.55, 29.12], [50.22, 50.22],]
		# equal bounds case is motivated because special handling of equal bound sets type of s.distribution to a number rather than an instance of Uniform
		
	        s1 = DataGenerators.UniformSampler(params)
	        s2 = DataGenerators.UniformSampler(otherparams)
	        traces = map(1:100) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams(s2, traces)

			@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Uniform(params[1],params[2]) x 
			end
			
	    end

	    @testset "too few traces" begin

	        params = [1.0, 6.0]
	        s1 = DataGenerators.UniformSampler(params)
	        s2 = DataGenerators.UniformSampler(otherparams)
	        traces = map(1:1) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams(s2, traces)

			@mtestset "consistent with uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Uniform(-42.9,42.2) x 
			end

	    end

	end
		
end

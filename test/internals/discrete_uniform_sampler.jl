@testset "discrete uniform sampler" begin

	cc = dummyChoiceContext()

	@testset "getparams, numparams, paramranges, sample" begin

		@testset "using default construction" begin
		
			s = DataGenerators.DiscreteUniformSampler()

			@testset "numparams and paramranges" begin
				@test DataGenerators.numparams(s) == 2
				prs = DataGenerators.paramranges(s)
				@test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
				@test prs == fill((Float64(typemin(Int)), Float64(typemax(Int))), 2)
			end
	
			@testset "default params" begin
				@test DataGenerators.getparams(s) == [Float64(typemin(Int)), Float64(typemax(Int))]
			end
	
			@mtestset "default sampling" reps=Main.REPS alpha=Main.ALPHA begin
				x, trace = DataGenerators.sample(s, (0,1), cc)
				@test typeof(x) <: Int
				# @test typemin(Int) <= x <= typemax(Int)
				# @mtest_distributed_as DiscreteUniform(typemin(Int),typemax(Int)) x
				# can't do above owing to problems with DiscreteUniform and large ranges, so instead:
				@mtest_that_sometimes x < (typemin(Int)>>1)
				@mtest_that_sometimes (typemin(Int)>>1) <= x < 0
				@mtest_that_sometimes 0 <= x < (typemax(Int)>>1)
				@mtest_that_sometimes (typemax(Int)>>1) <= x
			end
	
		end
		
	
		@testset "non-default construction" begin

			s = DataGenerators.DiscreteUniformSampler([-100.0,129.0])
	
			@testset "constructor with params" begin
		
				@test DataGenerators.getparams(s) == [-100.0,129.0]

				@mtestset "is consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
					x, trace = DataGenerators.sample(s, (0,1), cc)
			        @mtest_distributed_as DiscreteUniform(-100,129) x
				end
			
			end
		
		end
	
	end
	
	
	@testset "setparams" begin

	    s = DataGenerators.DiscreteUniformSampler()
	    prs = DataGenerators.paramranges(s)
	    midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

	    @testset "valid parameters $params" for params in [[8.0,50.0], [-3113.0, -2889.0],  [-6.0, 6.0],]

	        DataGenerators.setparams(s, params)

			@mtestset "consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as DiscreteUniform(Int(params[1]),Int(params[2])) x 
			end

	    end

		@testset "setparams adjusts order of parameters" begin

			DataGenerators.setparams(s, [50.0,8.0])
			@test DataGenerators.getparams(s) == [8.0,50.0]

			@mtestset "consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as DiscreteUniform(8,50) x 
			end

		end

		@testset "handles full Int range" begin
			params = [Float64(typemin(Int)), Float64(typemax(Int))]
			DataGenerators.setparams(s, params)

			@mtestset "consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        # @mtest_distributed_as DiscreteUniform(typemin(Int),typemax(Int)) x
				# can't do above owing to problems with DiscreteUniform and large ranges, so instead:
				@mtest_that_sometimes x < (typemin(Int)>>1)
				@mtest_that_sometimes (typemin(Int)>>1) <= x < 0
				@mtest_that_sometimes 0 <= x < (typemax(Int)>>1)
				@mtest_that_sometimes (typemax(Int)>>1) <= x
			end

		end

	    @testset "boundary values for parameter index $pidx" for pidx in 1:length(prs)

	        pr = prs[pidx]
	        params = copy(midparams)

			@testset "bound index $bidx" for bidx in 1:2

	            params[pidx] = pr[bidx] 
		        DataGenerators.setparams(s, params)

				sortedparams = sort(params)
				q1 = 0.75 * sortedparams[1] + 0.25 * sortedparams[2]
				q2 = 0.5 * sortedparams[1] + 0.5 * sortedparams[2]
				q3 = 0.25 * sortedparams[1] + 0.75 * sortedparams[2]
				@mtestset "consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
		        	x, trace = DataGenerators.sample(s, (0,1), cc)
					@test sortedparams[1] <= x <= sortedparams[2]
			        # @mtest_distributed_as DiscreteUniform(Int(sortedparams[1]),Int(sortedparams[2])) x
					# can't do above owing to problems with DiscreteUniform and large ranges, so instead:
					@mtest_that_sometimes x < q1
					@mtest_that_sometimes q1 <= x < q2
					@mtest_that_sometimes q2 <= x < q3
					@mtest_that_sometimes q3 <= x
				end
				
				@testset "range check exception" begin
		            params[pidx] = bidx == 1 ? prevfloat(pr[bidx]) : nextfloat(pr[bidx])
		            @test_throws ErrorException DataGenerators.setparams(s, params)
				end
				
			end

	    end

		@testset "handles non-integer parameters sensibly" begin

	        DataGenerators.setparams(s, [-2.9, 8.6])
			
			@mtestset "consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
				@test -2.9 <= x <= 8.6 # lower bound rounded up, upper bound rounded down
		        @mtest_distributed_as DiscreteUniform(-2,8) x 
			end
			
		end
		
	    @testset "wrong number of parameters" begin
	        @test_throws ErrorException DataGenerators.setparams(s, midparams[1:end-1])
	        @test_throws ErrorException DataGenerators.setparams(s, [midparams; 0.5])
	    end

	end
	
	
	@testset "estimateparams" begin

	   	otherparams = [-42.0, 42.0]

	    @testset "from parameters $params" for params in [[20.0, 29.0], [50.0, 50.0],]

	        s1 = DataGenerators.DiscreteUniformSampler(params)
	        s2 = DataGenerators.DiscreteUniformSampler(otherparams)
	        traces = map(1:100) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams(s2, traces)

			@mtestset "consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as DiscreteUniform(Int(params[1]),Int(params[2])) x 
			end
			
	    end

	    @testset "too few traces" begin

	        params = [1.0, 6.0]
	        s1 = DataGenerators.DiscreteUniformSampler(params)
	        s2 = DataGenerators.DiscreteUniformSampler(otherparams)
	        traces = map(1:1) do i
	            x, trace = DataGenerators.sample(s1, (0,1), cc)
	            trace
	        end
	        estimateparams(s2, traces)

			@mtestset "consistent with discrete uniform" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s2, (0,1), cc)
		        @mtest_distributed_as DiscreteUniform(-42,42) x 
			end

	    end

	end
		
end

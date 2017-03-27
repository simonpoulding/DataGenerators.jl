@testset "geometric sampler" begin

	cc = dummyChoiceContext()
	cc.derivationstate.currentrecursiondepth = 3
	
	@testset "getparams, numparams, paramranges, sample" begin

		@testset "using default construction" begin
		
		    s = DataGenerators.RecursionDepthSampler(DataGenerators.GeometricSampler(), 3)

		    @testset "numparams and paramranges" begin
		        @test DataGenerators.numparams(s) == 3
		        prs = DataGenerators.paramranges(s)
		        @test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
		        @test prs == [(0.0,1.0),(0.0,1.0),(0.0,1.0)]
		    end
	
		    @testset "default params" begin
		        @test DataGenerators.getparams(s) == [0.5, 0.5, 0.5]
		    end

			@mtestset "default sampling consistent with base sampler depth 3" reps=Main.REPS alpha=Main.ALPHA begin
				x, trace = DataGenerators.sample(s, (0,1), cc)
				@test typeof(x) <: Int
				@mtest_values_include [0,1,2] x
				@mtest_distributed_as Geometric(0.5) x
			end
		
		end
	
		@testset "using non-default construction" begin

		    s = DataGenerators.RecursionDepthSampler(DataGenerators.GeometricSampler(), 3, [0.5, 0.1, 0.7])
		    @test DataGenerators.getparams(s) == [0.5, 0.1, 0.7]

		    @mtestset "default sampling consistent with base sampler depth 3" reps=Main.REPS alpha=Main.ALPHA begin
		    	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Geometric(0.7) x
		    end

		end
		
	end
	
	@testset "getparams, numparams, paramranges, sample using multi-parameter base sampler" begin

		@testset "using default construction" begin
		
		    s = DataGenerators.RecursionDepthSampler(DataGenerators.CategoricalSampler(4), 2)

		    @testset "numparams and paramranges" begin
		        @test DataGenerators.numparams(s) == 8
		        prs = DataGenerators.paramranges(s)
		        @test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
		        @test prs == [(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),]
		    end
	
		    @testset "default params" begin
		        @test DataGenerators.getparams(s) == [0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,]
		    end

			@mtestset "consistent with base sampler max depth" reps=Main.REPS alpha=Main.ALPHA begin
				x, trace = DataGenerators.sample(s, (0,1), cc)
				@test typeof(x) <: Int
				@mtest_values_are [1,2,3,4] x
				@mtest_distributed_as Categorical(4) x
			end
		
		end
	
		@testset "using non-default construction" begin

		    s = DataGenerators.RecursionDepthSampler(DataGenerators.CategoricalSampler(4), 2, [0.25, 0.25, 0.25, 0.25, 0.1, 0.2, 0.3, 0.4,])
		    @test DataGenerators.getparams(s) == [0.25, 0.25, 0.25, 0.25, 0.1, 0.2, 0.3, 0.4,]

		    @mtestset "consistent with base sampler max depth" reps=Main.REPS alpha=Main.ALPHA begin
		    	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Categorical([0.1, 0.2, 0.3, 0.4,]) x
		    end

		end
		
	end
	

	@testset "setparams" begin

		s = DataGenerators.RecursionDepthSampler(DataGenerators.GeometricSampler(), 3)

	    @testset "valid parameters $params" for params in [[0.8, 0.4, 0.8,], [0.5, 0.1, 0.5], [0.7, 0.4, 0.6],]

	        DataGenerators.setparams!(s, params)

			@mtestset "consistent with base sampler depth 3" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Geometric(params[3]) x
			end

	    end

	    @testset "wrong number of parameters" begin

	        @test_throws ErrorException DataGenerators.setparams!(s, [0.8, 0.4,])
	        @test_throws ErrorException DataGenerators.setparams!(s, [0.8, 0.4, 0.1, 0.3])

	    end

	end

	@testset "setparams using multi-parameter base sampler" begin

		s = DataGenerators.RecursionDepthSampler(DataGenerators.CategoricalSampler(2), 3)

	    @testset "valid parameters $params" for params in [[0.5, 0.5, 0.5, 0.5, 0.5, 0.5,], [0.5, 0.5, 0.2, 0.8, 0.4, 0.6,], [0.3, 0.7, 0.1, 0.9, 0.7, 0.3,],]

	        DataGenerators.setparams!(s, params)

			@mtestset "consistent with base sampler depth 3" reps=Main.REPS alpha=Main.ALPHA begin
	        	x, trace = DataGenerators.sample(s, (0,1), cc)
		        @mtest_distributed_as Categorical(params[5:6]) x
			end

	    end

	    @testset "wrong number of parameters" begin

	        @test_throws ErrorException DataGenerators.setparams!(s, [0.5, 0.5, 0.5, 0.5, 0.5,])
	        @test_throws ErrorException DataGenerators.setparams!(s, [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5,])

	    end

	end

	@testset "estimateparams" begin

		params = [0.7, 0.4, 0.7,]
	    otherparams = [0.5, 0.7, 0.5,]

	    @testset "from sufficient traces" begin

			s1 = DataGenerators.RecursionDepthSampler(DataGenerators.GeometricSampler(), 3, params)
			cc1 = dummyChoiceContext()

			alltraces = Any[]
			for depth in 1:3
				cc1.derivationstate.currentrecursiondepth = depth
		        traces = map(1:100) do i
		            x, trace = DataGenerators.sample(s1, (0,1), cc1)
		            trace
		        end
				alltraces = [alltraces; traces]
			end
        
			s2 = DataGenerators.RecursionDepthSampler(DataGenerators.GeometricSampler(), 3, otherparams)
		    estimateparams!(s2, alltraces)

			cc2 = dummyChoiceContext()

			@mtestset "consistent with otherparams for depth $depth" reps=Main.REPS alpha=Main.ALPHA for depth in 1:3
				cc2.derivationstate.currentrecursiondepth = depth
	        	x, trace = DataGenerators.sample(s2, (0,1), cc2)
		        @mtest_distributed_as Geometric(params[depth]) x
			end

	    end

	    @testset "too few traces" begin

			s1 = DataGenerators.RecursionDepthSampler(DataGenerators.GeometricSampler(), 3, params)
			cc1 = dummyChoiceContext()

			alltraces = Any[]
			for depth in [1,3]
				cc1.derivationstate.currentrecursiondepth = depth
		        traces = map(1:100) do i
		            x, trace = DataGenerators.sample(s1, (0,1), cc1)
		            trace
		        end
				alltraces = [alltraces; traces]
			end
        
			s2 = DataGenerators.RecursionDepthSampler(DataGenerators.GeometricSampler(), 3, otherparams)
		    estimateparams!(s2, alltraces)

			cc2 = dummyChoiceContext()

			@mtestset "consistent with otherparams for depth $depth" reps=Main.REPS alpha=Main.ALPHA for depth in 2
				cc2.derivationstate.currentrecursiondepth = depth
	        	x, trace = DataGenerators.sample(s2, (0,1), cc2)
		        @mtest_distributed_as Geometric(otherparams[depth]) x
			end

	    end

	end

end

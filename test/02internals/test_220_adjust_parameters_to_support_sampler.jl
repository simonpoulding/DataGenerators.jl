include("sampler_test_utils.jl")

describe("Adjust Parameters to Support Sampler") do

	describe("construction") do
		
		subsA = GodelTest.UniformSampler([7.1,9.2])
		s = GodelTest.AdjustParametersToSupportSampler(subsA)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == 0
			prs = GodelTest.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == (Float64,Float64)[]
		end
	
		test("default params") do
			ps = GodelTest.getparams(s)
			@check typeof(ps) <: Vector{Float64}
			@check ps == Float64[]
		end

		test("set params") do
			GodelTest.setparams(s, Float64[])
			@check_throws GodelTest.setparams(s, [0.0])
		end
		
		test("validates subsampler of supported types") do
			@check_throws GodelTest.AdjustParametersToSupportSampler(GodelTest.Geometric())
		end
			
	end
	
	describe("sampling") do

		subsA = GodelTest.DiscreteUniformSampler([-1000.0, 214455.0])
		s = GodelTest.AdjustParametersToSupportSampler(subsA)

		@repeat test("random support") do
			bounds = rand(-200:200,2)
			l, u = minimum(bounds), maximum(bounds)
			x, trace = GodelTest.sample(s, (l, u))
			@check l <= x <= u
		end

		test("equal support") do
			bound = rand(-200:200)
			for i in 1:100
				x, trace = GodelTest.sample(s, (bound, bound))
				@check x == bound
			end
		end
		
	end
	
	describe("estimate parameters") do
		
		test("no parameters to estimate") do		

			subparams = [9.3, 15.8]
			subs1A = GodelTest.UniformSampler(subparams)
			s1 =GodelTest.AdjustParametersToSupportSampler(subs1A)

			othersubparams = [-55.1, -4.2]
			subs2A = GodelTest.UniformSampler(othersubparams)
			s2 =GodelTest.AdjustParametersToSupportSampler(subs2A)	

			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end

			estimateparams(s2, traces)
			@check GodelTest.getparams(subs2A) == othersubparams

		end
		
	end
		
end

include("sampler_test_utils.jl")

describe("Adjust Parameters to Support Sampler") do

	describe("construction") do
		
		subsA = DataGenerators.UniformSampler([7.1,9.2])
		s = DataGenerators.AdjustParametersToSupportSampler(subsA)

		test("numparams and paramranges") do
			@check DataGenerators.numparams(s) == 0
			prs = DataGenerators.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == (Float64,Float64)[]
		end
	
		test("default params") do
			ps = DataGenerators.getparams(s)
			@check typeof(ps) <: Vector{Float64}
			@check ps == Float64[]
		end

		test("set params") do
			DataGenerators.setparams(s, Float64[])
			@check_throws DataGenerators.setparams(s, [0.0])
		end
		
		test("validates subsampler of supported types") do
			@check_throws DataGenerators.AdjustParametersToSupportSampler(DataGenerators.Geometric())
		end
			
	end
	
	describe("sampling") do

		subsA = DataGenerators.DiscreteUniformSampler([-1000.0, 214455.0])
		s = DataGenerators.AdjustParametersToSupportSampler(subsA)

		@repeat test("random support") do
			bounds = rand(-200:200,2)
			l, u = minimum(bounds), maximum(bounds)
			x, trace = DataGenerators.sample(s, (l, u))
			@check l <= x <= u
		end

		test("equal support") do
			bound = rand(-200:200)
			for i in 1:100
				x, trace = DataGenerators.sample(s, (bound, bound))
				@check x == bound
			end
		end
		
	end
	
	describe("estimate parameters") do
		
		test("no parameters to estimate") do		

			subparams = [9.3, 15.8]
			subs1A = DataGenerators.UniformSampler(subparams)
			s1 =DataGenerators.AdjustParametersToSupportSampler(subs1A)

			othersubparams = [-55.1, -4.2]
			subs2A = DataGenerators.UniformSampler(othersubparams)
			s2 =DataGenerators.AdjustParametersToSupportSampler(subs2A)	

			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end

			estimateparams(s2, traces)
			@check DataGenerators.getparams(subs2A) == othersubparams

		end
		
	end
		
end

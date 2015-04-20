include("sampler_test_utils.jl")

describe("Adjust Parameters to Support Sampler") do

	describe("construction") do
		
		s1 = GodelTest.UniformSampler([7.1,9.2])
		s = GodelTest.AdjustParametersToSupportSampler(s1)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == 0
			@check GodelTest.paramranges(s) == (Float64,Float64)[]
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == Float64[]
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

		s1 = GodelTest.DiscreteUniformSampler([-1000.0, 214455.0])
		s = GodelTest.AdjustParametersToSupportSampler(s1)

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
		
end

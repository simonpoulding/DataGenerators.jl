include("sampler_test_utils.jl")

describe("Align Minimum Support Sampler") do

	describe("construction") do
		
		subsA = DataGenerators.GeometricSampler()
		s = DataGenerators.AlignMinimumSupportSampler(subsA)

		test("numparams and paramranges") do
			@check DataGenerators.numparams(s) == DataGenerators.numparams(subsA)
			@check DataGenerators.paramranges(s) == DataGenerators.paramranges(subsA)
		end
	
		test("default params") do
			@check DataGenerators.getparams(s) == DataGenerators.getparams(subsA)
		end

		test("set params") do
			DataGenerators.setparams(s, [0.4])
			@check DataGenerators.getparams(subsA) == [0.4]
			@check DataGenerators.getparams(s) == [0.4]
		end
					
	end
	
	describe("sampling") do

		subsA = DataGenerators.GeometricSampler([0.3])
		s = DataGenerators.AlignMinimumSupportSampler(subsA)

		support = (17, typemax(Int))
		@repeat test("aligns support") do
			x, trace = DataGenerators.sample(s, support)
			@check 17 <= x
		end

	end
	
	describe("estimate parameters") do
		
		test("estimates parameters of subsampler") do		

			subs1A = DataGenerators.GeometricSampler()
			s1 = DataGenerators.AlignMinimumSupportSampler(subs1A)
			params = [0.6]
			DataGenerators.setparams(s1, params)

			subs2A = DataGenerators.GeometricSampler()
			s2 = DataGenerators.AlignMinimumSupportSampler(subs2A)
			otherparams = [0.3]
			DataGenerators.setparams(s2, otherparams)

			traces = map(1:100) do i
			 	# note: varying support
				bounds = [rand(-100:100) for j in 1:2]
				x, trace = DataGenerators.sample(s1, (minimum(bounds),maximum(bounds)))
				trace
			end

			estimateparams(s2, traces)
			
			@check isconsistentgeometric(subs2A, params[1:1])

		end
		
	end
		
end

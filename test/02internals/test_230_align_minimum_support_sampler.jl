include("sampler_test_utils.jl")

describe("Align Minimum Support Sampler") do

	describe("construction") do
		
		subsA = GodelTest.GeometricSampler()
		s = GodelTest.AlignMinimumSupportSampler(subsA)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == GodelTest.numparams(subsA)
			@check GodelTest.paramranges(s) == GodelTest.paramranges(subsA)
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == GodelTest.getparams(subsA)
		end

		test("set params") do
			GodelTest.setparams(s, [0.4])
			@check GodelTest.getparams(subsA) == [0.4]
			@check GodelTest.getparams(s) == [0.4]
		end
					
	end
	
	describe("sampling") do

		subsA = GodelTest.GeometricSampler([0.3])
		s = GodelTest.AlignMinimumSupportSampler(subsA)

		support = (17, typemax(Int))
		@repeat test("aligns support") do
			x, trace = GodelTest.sample(s, support)
			@check 17 <= x
		end

	end
	
	describe("estimate parameters") do
		
		test("estimates parameters of subsampler") do		

			subs1A = GodelTest.GeometricSampler()
			s1 = GodelTest.AlignMinimumSupportSampler(subs1A)
			params = [0.6]
			GodelTest.setparams(s1, params)

			subs2A = GodelTest.GeometricSampler()
			s2 = GodelTest.AlignMinimumSupportSampler(subs2A)
			otherparams = [0.3]
			GodelTest.setparams(s2, otherparams)

			traces = map(1:100) do i
			 	# note: varying support
				bounds = [rand(-100:100) for j in 1:2]
				x, trace = GodelTest.sample(s1, (minimum(bounds),maximum(bounds)))
				trace
			end

			estimateparams(s2, traces)
			
			@check isconsistentgeometric(subs2A, params[1:1])

		end
		
	end
		
end

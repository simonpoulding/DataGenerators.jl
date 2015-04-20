include("sampler_test_utils.jl")

describe("Align Minimum Support Sampler") do

	describe("construction") do
		
		s1 = GodelTest.GeometricSampler()
		s = GodelTest.AlignMinimumSupportSampler(s1)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == GodelTest.numparams(s1)
			@check GodelTest.paramranges(s) == GodelTest.paramranges(s1)
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == GodelTest.getparams(s1)
		end

		test("set params") do
			GodelTest.setparams(s, [0.4])
			@check GodelTest.getparams(s1) == [0.4]
			@check GodelTest.getparams(s) == [0.4]
		end
					
	end
	
	describe("sampling") do

		s1 = GodelTest.GeometricSampler([0.3])
		s = GodelTest.AlignMinimumSupportSampler(s1)

		support = (17, typemax(Int))
		@repeat test("aligns support") do
			x, trace = GodelTest.sample(s, support)
			@check 17 <= x
		end

	end
		
end

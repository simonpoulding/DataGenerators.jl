include("sampler_test_utils.jl")

describe("Transform Sampler") do

	describe("construction") do
		
		s1 = GodelTest.UniformSampler([2.6, 3.1])
		s = GodelTest.TransformSampler(s1, x->2.0*x, x->0.5*x)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == GodelTest.numparams(s1)
			@check GodelTest.paramranges(s) == GodelTest.paramranges(s1)
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == GodelTest.getparams(s1)
		end

		test("set params") do
			GodelTest.setparams(s, [-5.11, -3.22])
			@check GodelTest.getparams(s1) == [-5.11, -3.22]
			@check GodelTest.getparams(s) == [-5.11, -3.22]
		end
					
	end
	
	describe("sampling") do

		s1 = GodelTest.UniformSampler([2.6, 3.1])
		s = GodelTest.TransformSampler(s1, x->2.0*x, x->0.5*x)

		@repeat test("sampling within transformed range") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Float64
			@check 5.2 <= x <= 6.2
		end

	end

	describe("sampling where support affects outcome") do

		s1 = GodelTest.AdjustParametersToSupportSampler(GodelTest.UniformSampler())
		s = GodelTest.TransformSampler(s1, x->2.0*x, x->0.5*x)

		@repeat test("sampling within support") do
			x, trace = GodelTest.sample(s, (110.7,190.4))
			@check typeof(x) <: Float64
			@check 110.7 <= x <= 190.4
		end

	end
		
end

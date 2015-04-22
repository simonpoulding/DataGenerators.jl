include("sampler_test_utils.jl")

describe("Transform Sampler") do

	describe("construction") do
		
		subsA = GodelTest.UniformSampler([2.6, 3.1])
		s = GodelTest.TransformSampler(subsA, x->2.0*x, x->0.5*x)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == GodelTest.numparams(subsA)
			@check GodelTest.paramranges(s) == GodelTest.paramranges(subsA)
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == GodelTest.getparams(subsA)
		end

		test("set params") do
			GodelTest.setparams(s, [-5.11, -3.22])
			@check GodelTest.getparams(subsA) == [-5.11, -3.22]
			@check GodelTest.getparams(s) == [-5.11, -3.22]
		end
					
	end
	
	describe("sampling") do

		subsA = GodelTest.UniformSampler([2.6, 3.1])
		s = GodelTest.TransformSampler(subsA, x->2.0*x, x->0.5*x)

		@repeat test("sampling within transformed range") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Float64
			@check 5.2 <= x <= 6.2
		end

	end

	describe("sampling where support affects outcome") do

		subsA = GodelTest.AdjustParametersToSupportSampler(GodelTest.UniformSampler())
		s = GodelTest.TransformSampler(subsA, x->2.0*x, x->0.5*x)

		@repeat test("sampling within support") do
			x, trace = GodelTest.sample(s, (110.7,190.4))
			@check typeof(x) <: Float64
			@check 110.7 <= x <= 190.4
		end

	end
	
	describe("estimate parameters") do
		
		test("estimates parameters of subsampler") do		

			subs1A = GodelTest.GeometricSampler()
			s1 = GodelTest.TransformSampler(subs1A, x->x+10.0, x->x-10.0)
			params = [0.7]
			GodelTest.setparams(s1, params)
			
			subs2A = GodelTest.GeometricSampler()
			s2 = GodelTest.TransformSampler(subs2A, x->x+10.0, x->x-10.0)
			otherparams = [0.3]
			GodelTest.setparams(s2, otherparams)

			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0, 1))
				trace
			end

			estimateparams(s2, traces)
			
			@check isconsistentgeometric(subs2A, params[1:1])

		end
		
	end
		
end

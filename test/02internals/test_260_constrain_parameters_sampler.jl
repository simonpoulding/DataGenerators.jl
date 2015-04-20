include("sampler_test_utils.jl")

describe("Constrain Parameters Sampler") do

	describe("construction") do
		
		s1 = GodelTest.CategoricalSampler(2)

		test("numparams, paramranges, getparams") do
			cprs = [(0.2, 0.7), (0.3, 0.6)]
			s = GodelTest.ConstrainParametersSampler(s1, cprs)
			@check GodelTest.paramranges(s) == cprs
			@check GodelTest.numparams(s) == GodelTest.numparams(s1)
			@check GodelTest.getparams(s) == GodelTest.getparams(s1)
		end
	
		test("wrong number of parameter ranges") do
			cprs = [(0.2, 0.7)]
			@check_throws GodelTest.ConstrainParametersSampler(s1, cprs)
			cprs = [(0.2, 0.7), (0.3, 0.6), (0.4, 0.8)]
			@check_throws GodelTest.ConstrainParametersSampler(s1, cprs)
		end

		test("invalid order of parameter range bounds") do
			cprs = [(0.2, 0.7), (0.6, 0.3)]
			@check_throws GodelTest.ConstrainParametersSampler(s1, cprs)
		end

		test("constrained parameter ranges are outside subsampler parameter") do
			cprs = [(1.2, 1.7), (0.3, 0.6)]
			@check_throws GodelTest.ConstrainParametersSampler(s1, cprs)
		end

		test("set params") do
			cprs = [(0.2, 0.7), (0.3, 0.6)]
			s = GodelTest.ConstrainParametersSampler(s1, cprs)
			GodelTest.setparams(s, [0.5, 0.5])
			@check GodelTest.getparams(s1) == [0.5, 0.5]
			GodelTest.setparams(s, [0.7, 0.3])
			@check GodelTest.getparams(s1) == [0.7, 0.3]
			GodelTest.setparams(s, [0.2, 0.6])
			ps = GodelTest.getparams(s1)
			@check abs(ps[1]-0.25) <= 1e-5
			@check abs(ps[2]-0.75) <= 1e-5
			@check_throws GodelTest.setparams(s, [0.2])
			@check_throws GodelTest.setparams(s, [0.2, 0.6, 0.2])
			@check_throws GodelTest.setparams(s, [prevfloat(0.2), 0.5])
			@check_throws GodelTest.setparams(s, [nextfloat(0.7), 0.5])
			@check_throws GodelTest.setparams(s, [0.5, prevfloat(0.3)])
			@check_throws GodelTest.setparams(s, [0.5, nextfloat(0.6)])
		end
					
	end
	
	describe("sampling") do

		s1 = GodelTest.NormalSampler([2.0, 1.0])
		s = GodelTest.ConstrainParametersSampler(s1, [(1.0,10.0), (1.0,5.0)])

		test("sampling is of subsampler") do
			@check isconsistentnormal(s, GodelTest.getparams(s1))
		end

	end
			
end

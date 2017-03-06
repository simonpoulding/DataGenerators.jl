include("sampler_test_utils.jl")

describe("Constrain Parameters Sampler") do

	describe("construction") do
		
		subsA = DataGenerators.CategoricalSampler(2)

		test("numparams, paramranges, getparams") do
			cprs = [(0.2, 0.7), (0.3, 0.6)]
			s = DataGenerators.ConstrainParametersSampler(subsA, cprs)
			@check DataGenerators.paramranges(s) == cprs
			@check DataGenerators.numparams(s) == DataGenerators.numparams(subsA)
			@check DataGenerators.getparams(s) == DataGenerators.getparams(subsA)
		end
	
		test("wrong number of parameter ranges") do
			cprs = [(0.2, 0.7)]
			@check_throws DataGenerators.ConstrainParametersSampler(subsA, cprs)
			cprs = [(0.2, 0.7), (0.3, 0.6), (0.4, 0.8)]
			@check_throws DataGenerators.ConstrainParametersSampler(subsA, cprs)
		end

		test("invalid order of parameter range bounds") do
			cprs = [(0.2, 0.7), (0.6, 0.3)]
			@check_throws DataGenerators.ConstrainParametersSampler(subsA, cprs)
		end

		test("constrained parameter ranges are outside subsampler parameter") do
			cprs = [(1.2, 1.7), (0.3, 0.6)]
			@check_throws DataGenerators.ConstrainParametersSampler(subsA, cprs)
		end

		test("set params") do
			cprs = [(0.2, 0.7), (0.3, 0.6)]
			s = DataGenerators.ConstrainParametersSampler(subsA, cprs)
			DataGenerators.setparams(s, [0.5, 0.5])
			@check DataGenerators.getparams(subsA) == [0.5, 0.5]
			DataGenerators.setparams(s, [0.7, 0.3])
			@check DataGenerators.getparams(subsA) == [0.7, 0.3]
			DataGenerators.setparams(s, [0.2, 0.6])
			ps = DataGenerators.getparams(subsA)
			@check abs(ps[1]-0.25) <= 1e-5
			@check abs(ps[2]-0.75) <= 1e-5
			@check_throws DataGenerators.setparams(s, [0.2])
			@check_throws DataGenerators.setparams(s, [0.2, 0.6, 0.2])
			@check_throws DataGenerators.setparams(s, [prevfloat(0.2), 0.5])
			@check_throws DataGenerators.setparams(s, [nextfloat(0.7), 0.5])
			@check_throws DataGenerators.setparams(s, [0.5, prevfloat(0.3)])
			@check_throws DataGenerators.setparams(s, [0.5, nextfloat(0.6)])
		end
					
	end
	
	describe("sampling") do

		subsA = DataGenerators.NormalSampler([2.0, 1.0])
		s = DataGenerators.ConstrainParametersSampler(subsA, [(1.0,10.0), (1.0,5.0)])

		test("sampling is of subsampler") do
			@check isconsistentnormal(s, DataGenerators.getparams(subsA))
		end

	end
	
	describe("estimate parameters") do
		
		test("estimates parameters of subsampler") do		

			cprs = [(0.2, 0.8)]

			subs1A = DataGenerators.GeometricSampler()
			s1 = DataGenerators.ConstrainParametersSampler(subs1A, cprs)
			params = [0.25]
			DataGenerators.setparams(s1, params)
			
			subs2A = DataGenerators.GeometricSampler()
			s2 = DataGenerators.ConstrainParametersSampler(subs2A, cprs)
			otherparams = [0.6]
			DataGenerators.setparams(s2, otherparams)

			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0, 1))
				trace
			end

			estimateparams(s2, traces)
			
			@check isconsistentgeometric(subs2A, params[1:1])

		end
		
	end
			
end

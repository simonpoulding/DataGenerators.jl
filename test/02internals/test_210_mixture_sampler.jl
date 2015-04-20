include("sampler_test_utils.jl")

describe("Mixture Sampler") do

	describe("construction") do
		
		s1 = GodelTest.BernoulliSampler()
		s2 = GodelTest.DiscreteUniformSampler([7.0,9.0])
		s = GodelTest.MixtureSampler(s1,s2)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == 2 + GodelTest.numparams(s1) + GodelTest.numparams(s2)
			prs = GodelTest.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == [(0.0,1.0), (0.0,1.0), GodelTest.paramranges(s1), GodelTest.paramranges(s2)]
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == [0.5, 0.5, GodelTest.getparams(s1), GodelTest.getparams(s2)]
		end
	
		@repeat test("default sampling") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Int
			@mcheck_values_are x [0,1,7,8,9]
		end
		
	end
	
	describe("parameter setting") do
	
		s1 = GodelTest.BernoulliSampler()
		s2 = GodelTest.DiscreteUniformSampler()
		s3 = GodelTest.GeometricSampler()
		s = GodelTest.MixtureSampler(s1,s2,s3)
		prs = GodelTest.paramranges(s)
		midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

		test("setparams with wrong number of parameters") do
			@check_throws GodelTest.setparams(s, midparams[1:end-1])
			@check_throws GodelTest.setparams(s, [midparams, 0.5])
		end

		test("setparams sets parameters of subsamplers") do
			params = [0.1, 0.2, 0.7, 0.4, 1.0, 6.0, 0.1]
			GodelTest.setparams(s, params)
			@check GodelTest.getparams(s1) == [0.4]
			@check GodelTest.getparams(s2) == [1.0, 6.0]
			@check GodelTest.getparams(s3) == [0.1]
		end

		test("setparams sets parameters of internal choice") do
			params = [1.0, 0.0, 0.0, 0.4, 1.0, 6.0, 0.1]
			GodelTest.setparams(s, params)
			@check isconsistentbernoulli(s, params[4:4])
			params = [0.0, 1.0, 0.0, 0.4, 1.0, 6.0, 0.1]
			GodelTest.setparams(s, params)
			@check isconsistentdiscreteuniform(s, params[5:6])
			params = [0.0, 0.0, 1.0, 0.4, 1.0, 6.0, 0.1]
			GodelTest.setparams(s, params)
			@check isconsistentgeometric(s, params[7:7])
		end

		@repeat test("setparams with random parameters") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			GodelTest.setparams(s, params)
		end
		
	end
		
end

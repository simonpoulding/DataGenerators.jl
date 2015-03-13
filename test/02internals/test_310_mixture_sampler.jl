include("mock_choice_context.jl")

describe("Mixture Sampler") do

	test("constructor") do
		s = GodelTest.MixtureSampler([GodelTest.UniformSampler(), GodelTest.GaussianSampler()])
		@check typeof(s.internaldist) == GodelTest.CategoricalDist
		s = GodelTest.MixtureSampler([GodelTest.GeometricSampler(),GodelTest.DiscreteUniformSampler(),GodelTest.BernoulliSampler()])
		@check_throws s = GodelTest.MixtureSampler()
		@check_throws s = GodelTest.MixtureSampler([GodelTest.GeometricSampler()])
	end

	test("numparams") do
		s = GodelTest.MixtureSampler([GodelTest.GeometricSampler(),GodelTest.DiscreteUniformSampler(),GodelTest.BernoulliSampler()])
		@check GodelTest.numparams(s) == 5 # = 3(internal) + 1 (Geometric) + 0 (DiscreteUniform) + 1 (Bernoulli)
	end

	test("paramranges") do
		s = GodelTest.MixtureSampler([GodelTest.GeometricSampler(),GodelTest.DiscreteUniformSampler(),GodelTest.BernoulliSampler()])
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check pr == [(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0)] # internal + Geometric + Bernoulli
	end 

	test("getparams and default") do
		s = GodelTest.MixtureSampler([GodelTest.UniformSampler(), GodelTest.GaussianSampler()])
		ps = getparams(s)
		@check typeof(ps) == Vector{Float64}
		@check ps == [0.5, 0.5, 0.0, 1.0] # internal + Gaussian
	end

	test("setparams") do
		m1 = GodelTest.GeometricSampler()
		m2 = GodelTest.DiscreteUniformSampler()
		m3 = GodelTest.BernoulliSampler()
		s = GodelTest.MixtureSampler([m1, m2, m3])
		setparams(s, [0.1, 0.5, 0.4, 0.8, 0.17])
		@check getparams(s.internaldist) == [0.1, 0.5, 0.4]
		@check getparams(m1) == [0.8]
		@check getparams(m2) == []
		@check getparams(m3) == [0.17]
	end

	describe("godelnumber") do
	
		s = GodelTest.MixtureSampler([GodelTest.GeometricSampler(),GodelTest.DiscreteUniformSampler(),GodelTest.BernoulliSampler()])
		cc = mockCC(-3,1,Int64)
	
		@repeat test("godelnumber sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_values_are gn [-3,-2,-1,0,1]
		end
		
	end
	
end

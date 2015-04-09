describe("Bernoulli Sampler") do

	test("constructor") do
		s = GodelTest.BernoulliSampler()
		@check s.paramranges == [(0.0,1.0)]
		@check s.params == [0.5]
		@check typeof(s.distribution) == Distributions.Bernoulli
		@check s.distribution.p == 0.5
	end
	
	test("constructor with params") do
		s = GodelTest.BernoulliSampler([0.37])
		@check s.paramranges == [(0.0,1.0)]
		@check s.params == [0.37]
		@check typeof(s.distribution) == Distributions.Bernoulli
		@check s.distribution.p == 0.37
	end
	
	test("numparams") do
		s = GodelTest.BernoulliSampler()
		@check GodelTest.numparams(s) == 1
	end

	test("paramranges") do
		s = GodelTest.BernoulliSampler()
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check pr == [(0.0,1.0)]
	end

	test("setparams") do
		s = GodelTest.BernoulliSampler()
		setparams(s, [0.7])
		@check s.params == [0.7]
		@check typeof(s.distribution) == Distributions.Bernoulli
		@check s.distribution.p == 0.7
	end
	
	test("setparams checks") do
		s = GodelTest.BernoulliSampler()
		@check_throws setparams(s, []) # too few params
		@check_throws setparams(s, [0.4, 0.6]) # too many params
		setparams(s,[1.0])
		@check s.distribution.p == 1.0
		@check_throws setparams(s, [1.01]) # > 1
		setparams(s,[0.0])
		@check s.distribution.p == 0.0
		@check_throws setparams(s, [-0.01]) # < 0
	end

	test("getparams") do
		s = GodelTest.BernoulliSampler()
		setparams(s, [0.4])
		@check getparams(s) == [0.4]
	end

	describe("sampling") do

		s = GodelTest.BernoulliSampler()

		@repeat test("across full range of support") do
			x = GodelTest.sample(s, [0,1])
			@check typeof(x) == Int64
			@mcheck_values_are x [0,1]
		end

		@repeat test("with random parameters is within range of support") do
			setparams(s, [rand()])
			x = GodelTest.sample(s, [-2,22])
			@check typeof(x) == Int64
			@check 0 <= x <= 1
		end

	end
	
end

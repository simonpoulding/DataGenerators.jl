describe("Bernoulli Dist") do

	describe("construction") do
		
		test("constructor") do
			d = GodelTest.BernoulliDist()
			@check typeof(d.distribution) == Distributions.Bernoulli
			@check d.paramranges == [(0.0,1.0)]
			@check d.params == [0.5]
			@check d.distribution.p == 0.5
		end
		
	end
	
	describe("parameters") do
		
		test("numparams") do
			d = GodelTest.BernoulliDist()
			@check GodelTest.numparams(d) == 1
		end

		test("paramranges") do
			d = GodelTest.BernoulliDist()
			pr = paramranges(d)
			@check typeof(pr) == Vector{(Float64,Float64)}
			@check pr == [(0.0,1.0)]
		end

		test("setparams") do
			d = GodelTest.BernoulliDist()
			setparams(d, [0.7])
			@check typeof(d.distribution) == Distributions.Bernoulli
			@check d.distribution.p == 0.7
			@check d.params == [0.7]
		end
		
		test("setparams checks") do
			d = GodelTest.BernoulliDist()
			@check_throws setparams(d, []) # too few params
			@check_throws setparams(d, [0.4, 0.6]) # too many params
			setparams(d,[1.0])
			@check d.distribution.p == 1.0
			@check_throws setparams(d, [1.01]) # > 1
			setparams(d,[0.0])
			@check d.distribution.p == 0.0
			@check_throws setparams(d, [-0.01]) # < 0
		end

		test("getparams") do
			d = GodelTest.BernoulliDist()
			setparams(d, [0.4])
			@check getparams(d) == [0.4]
		end
		
		test("supportlowerbound") do
			d = GodelTest.BernoulliDist()
			@check GodelTest.supportlowerbound(d) == 0
		end
		
	end

	describe("sampling") do

		d = GodelTest.BernoulliDist()

		@repeat test("across full range of support") do
			setparams(d, [0.5])
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@mcheck_values_are s [0,1]
		end

		@repeat test("with random parameters is within range of support") do
			setparams(d, [rand()])
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@check 0 <= s <= 1
		end

	end
	
end

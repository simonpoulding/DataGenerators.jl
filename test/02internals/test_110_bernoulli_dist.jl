describe("Bernoulli Dist") do

	test("constructor") do
		d = GodelTest.BernoulliDist()
		@check typeof(d.distribution) == Distributions.Bernoulli
		@check d.distribution.p == 0.5
		@check d.params == [0.5]
		@check d.nparams == 1
	end
	
	test("numparams") do
		d = GodelTest.BernoulliDist()
		@check numparams(d) == 1
	end

	test("paramranges") do
		d = GodelTest.BernoulliDist()
		pr = paramranges(d)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr)==1
		@check all(x->x==(0.0,1.0), pr)
	end

	test("setparams") do
		d = GodelTest.BernoulliDist()
		setparams(d, [0.7])
		@check typeof(d.distribution) == Distributions.Bernoulli
		@check d.distribution.p == 0.7
		@check d.params == [0.7]
		@check d.nparams == 1
	end

	# TODO check num param error

	test("invalid parameters are adjusted") do
		d = GodelTest.BernoulliDist()
		setparams(d, [1.1])
		@check d.params == [1.0]
		@check d.distribution.p == 1.0
		setparams(d, [-0.2])
		@check d.params == [0.0]
		@check d.distribution.p == 0.0
	end

	test("getparams") do
		d = GodelTest.BernoulliDist()
		setparams(d, [0.4])
		@check getparams(d) == [0.4]
	end

	describe("sample") do

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

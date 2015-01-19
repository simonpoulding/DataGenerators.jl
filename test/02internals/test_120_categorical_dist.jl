describe("Categorical Dist") do

	test("constructor") do
		d = GodelTest.CategoricalDist(4)
		@check typeof(d.distribution) == Distributions.Categorical
		@check d.distribution.K == 4
		@check d.distribution.p == [0.25, 0.25, 0.25, 0.25]
		@check d.params == [0.25, 0.25, 0.25, 0.25]
		@check d.nparams == 4
	end
	
	test("numparams") do
		d = GodelTest.CategoricalDist(7)
		@check numparams(d) == 7
	end

	test("paramranges") do
		d = GodelTest.CategoricalDist(13)
		pr = paramranges(d)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr)==13
		@check all(x->x==(0.0, 1.0), pr)
	end

	test("setparams") do
		d = GodelTest.CategoricalDist(3)
		setparams(d, [0.7, 0.1, 0.2])
		@check typeof(d.distribution) == Distributions.Categorical
		@check d.distribution.K == 3
		@check d.distribution.p == [0.7, 0.1, 0.2]
		@check d.params == [0.7, 0.1, 0.2]
		@check d.nparams == 3
	end

	# TODO check num param error

	test("invalid parameters are adjusted") do
		d = GodelTest.CategoricalDist(4)
		setparams(d, [0.2, 0.1, 0.1, 0.1])
		@check d.params == [0.4, 0.2, 0.2, 0.2]
		@check d.distribution.p == [0.4, 0.2, 0.2, 0.2]
		setparams(d, [0.5, 1.0, 0.5, 0.0])
		@check d.params == [0.25, 0.5, 0.25, 0.0]
		@check d.distribution.p == [0.25, 0.5, 0.25, 0.0]
		setparams(d, [0.0, 0.0, 0.0, 0.0])
		@check d.params == [0.25, 0.25, 0.25, 0.25]
		@check d.distribution.p == [0.25, 0.25, 0.25, 0.25]
	end

	test("getparams") do
		d = GodelTest.CategoricalDist(2)
		setparams(d, [0.4, 0.6])
		@check getparams(d) == [0.4, 0.6]
	end

	test("sample") do

		d = GodelTest.CategoricalDist(4)
	
		@repeat test("across full range of support") do
			setparams(d, [0.25, 0.25, 0.25, 0.25])
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@mcheck_values_are s [1,2,3,4]
		end

		@repeat test("random parameters") do
			setparams(d, [rand(), rand(), rand(), rand()])
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@check 1 <= s <= 4
		end
		
	end

	test("supportlowerbound") do
		d = GodelTest.CategoricalDist(6)
		@check GodelTest.supportlowerbound(d) == 1
	end
	
	# TODO supportlowerquartile
	
end

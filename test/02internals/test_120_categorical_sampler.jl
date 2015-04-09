describe("Categorical Sampler") do

	test("constructor") do
		s = GodelTest.CategoricalSampler(4)
		@check s.paramranges == [(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),]
		@check s.params == [0.25, 0.25, 0.25, 0.25,]			
		@check typeof(s.distribution) == Distributions.Categorical
		@check s.distribution.K == 4
		@check s.distribution.p == [0.25, 0.25, 0.25, 0.25,]
	end

	test("constructor checks") do
		@check_throws s = GodelTest.CategoricalSampler(0) # must be >= 1 categories
	end
		
	test("constructor with params") do
		s = GodelTest.CategoricalSampler(3, [0.8, 0.1, 0.1])
		@check s.paramranges == [(0.0,1.0),(0.0,1.0),(0.0,1.0),]
		@check s.params == [0.8, 0.1, 0.1,]			
		@check typeof(s.distribution) == Distributions.Categorical
		@check s.distribution.K == 3
		@check s.distribution.p == [0.8, 0.1, 0.1,]
	end
	
	test("numparams") do
		s = GodelTest.CategoricalSampler(7)
		@check GodelTest.numparams(s) == 7
	end

	test("paramranges") do
		s = GodelTest.CategoricalSampler(13)
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr)==13
		@check all(x->x==(0.0, 1.0), pr)
	end

	test("setparams") do
		s = GodelTest.CategoricalSampler(3)
		setparams(s, [0.7, 0.1, 0.2])
		@check typeof(s.distribution) == Distributions.Categorical
		@check s.distribution.K == 3
		@check s.distribution.p == [0.7, 0.1, 0.2]
		@check s.params == [0.7, 0.1, 0.2]
	end

	test("setparams checks") do
		s = GodelTest.CategoricalSampler(3)
		@check_throws setparams(s, [0.7, 0.3]) # too few params
		@check_throws setparams(s, [0.4, 0.2, 0.2, 0.2]) # too many params
		setparams(s, [0.0, 1.0, 0.0])
		@check s.distribution.p == [0.0, 1.0, 0.0]
		@check_throws setparams(s, [0.0, 1.01, 0.0]) # > 1
		@check_throws setparams(s, [0.0, 1.0, -0.01]) # < 0
	end

	test("setparams adjustments") do
		s = GodelTest.CategoricalSampler(4)
		setparams(s, [0.2, 0.1, 0.1, 0.1])
		@check s.params == [0.4, 0.2, 0.2, 0.2]
		@check s.distribution.p == [0.4, 0.2, 0.2, 0.2]
		setparams(s, [0.5, 1.0, 0.5, 0.0])
		@check s.params == [0.25, 0.5, 0.25, 0.0]
		@check s.distribution.p == [0.25, 0.5, 0.25, 0.0]
		setparams(s, [0.0, 0.0, 0.0, 0.0])
		@check s.params == [0.25, 0.25, 0.25, 0.25]
		@check s.distribution.p == [0.25, 0.25, 0.25, 0.25]
	end

	test("getparams") do
		s = GodelTest.CategoricalSampler(2)
		setparams(s, [0.4, 0.6])
		@check getparams(s) == [0.4, 0.6]
	end
		
	describe("sampling") do

		s = GodelTest.CategoricalSampler(4)
	
		@repeat test("across full range of support") do
			setparams(s, [0.25, 0.25, 0.25, 0.25],)
			x = GodelTest.sample(s, [1,4])
			@check typeof(x) == Int64
			@mcheck_values_are x [1,2,3,4]
		end

		@repeat test("random parameters") do
			setparams(s, [rand(), rand(), rand(), rand()])
			x = GodelTest.sample(s, [-32,10])
			@check typeof(x) == Int64
			@check 1 <= x <= 4
		end
		
	end

	
end

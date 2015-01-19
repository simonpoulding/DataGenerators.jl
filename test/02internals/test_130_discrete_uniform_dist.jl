describe("DiscreteUniform Dist") do

	test("constructor") do
		d = GodelTest.DiscreteUniformDist(1,6)
		@check typeof(d.distribution) == Distributions.DiscreteUniform
		@check d.distribution.a == 1
		@check d.distribution.b == 6
		@check d.params == Float64[]
		@check d.nparams == 0
	end
	
	test("numparams") do
		d = GodelTest.DiscreteUniformDist(1,6)
		@check numparams(d) == 0
	end

	test("paramranges") do
		d = GodelTest.DiscreteUniformDist(1,6)
		pr = paramranges(d)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr) == 0
	end

	test("setparams") do
		d = GodelTest.DiscreteUniformDist(-10,16)
		setparams(d, Float64[])
		@check typeof(d.distribution) == Distributions.DiscreteUniform
		@check d.distribution.a == -10
		@check d.distribution.b == 16
		@check d.params == Float64[]
		@check d.nparams == 0
	end

	# TODO check num param error

	test("getparams") do
		d = GodelTest.DiscreteUniformDist(1,6)
		@check getparams(d) == Float64[]
	end


	describe("sample") do

		d = GodelTest.DiscreteUniformDist(9,13)
	
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@mcheck_values_are s [9, 10, 11, 12, 13]
		end

	end

	describe("sample max upper") do

		d = GodelTest.DiscreteUniformDist(9,typemax(Int))
		@check d.upperbound == typemax(Int)
		@check d.distribution.b == typemax(Int)
		
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@check 9 <= s <= typemax(Int)
		end

	end

	describe("sample min lower") do

		d = GodelTest.DiscreteUniformDist(typemin(Int)+1,10)
		# typemin(Int) is not supported as lowerbound
		@check d.lowerbound == typemin(Int)+1
		@check d.distribution.a == typemin(Int)+1
		
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@check typemin(Int)+1 <= s <= 10
		end

	end

	describe("sample min lower and max upper") do

		d = GodelTest.DiscreteUniformDist(typemin(Int)+1,typemax(Int))
		# typemin(Int) is not supported as lowerbound
		@check d.lowerbound == typemin(Int)+1
		@check d.upperbound == typemax(Int)
		@check d.distribution.a == typemin(Int)+1
		@check d.distribution.b == typemax(Int)
		
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Int
			@check typemin(Int)+1 <= s <= typemax(Int)
			@mcheck_that_sometimes s < 0
			@mcheck_that_sometimes s > 0
		end

	end

	test("supportlowerbound") do
		d = GodelTest.DiscreteUniformDist(-19, 23)
		@check GodelTest.supportlowerbound(d) == -19
	end


end

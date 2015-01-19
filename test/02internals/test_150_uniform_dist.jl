describe("Uniform Dist") do

	test("constructor") do
		d = GodelTest.UniformDist(-2.3,4.22)
		@check typeof(d.distribution) == Distributions.Uniform
		@check d.distribution.a == -2.3
		@check d.distribution.b == 4.22
		@check d.params == Float64[]
		@check d.nparams == 0
	end
	
	test("numparams") do
		d = GodelTest.UniformDist(1.2,6.8)
		@check numparams(d) == 0
	end

	test("paramranges") do
	d = GodelTest.UniformDist(1.2,6.8)
		pr = paramranges(d)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr) == 0
	end

	test("setparams") do
		d = GodelTest.UniformDist(-1.0,1.6)
		setparams(d, Float64[])
		@check typeof(d.distribution) == Distributions.Uniform
		@check d.distribution.a == -1.0
		@check d.distribution.b == 1.6
		@check d.params == Float64[]
		@check d.nparams == 0
	end

	# TODO check num param error

	test("getparams") do
		d = GodelTest.UniformDist(-1.0,1.6)
		@check getparams(d) == Float64[]
	end

	describe("sample") do

		d = GodelTest.UniformDist(12.4,42.0)
	
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Float64
			@check 12.4 <= s <= 42.0
			@mcheck_that_sometimes s < 27.3 
			@mcheck_that_sometimes s > 27.3 
		end

	end
	
	describe("sample infinite upper") do

		d = GodelTest.UniformDist(9, Inf)
		@check d.upperbound == Inf
		@check d.distribution.b == Inf
		
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Float64
			@check s == Inf
		end

	end

	describe("sample infinite lower") do

		d = GodelTest.UniformDist(-Inf,10)
		@check d.lowerbound == -Inf
		@check d.distribution.a == -Inf
		
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Float64
			@check s == -Inf
		end

	end

	describe("sample infinite lower and max upper") do

		d = GodelTest.UniformDist(-Inf, Inf)
		@check d.lowerbound == -Inf
		@check d.upperbound == Inf
		@check d.distribution.a == -Inf
		@check d.distribution.b == Inf
		
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Float64
			@mcheck_values_are s [-Inf, Inf]
		end

	end

	test("supportlowerbound") do
		d = GodelTest.UniformDist(-1.2, 2.34)
		@check GodelTest.supportlowerbound(d) == -1.2
	end


end

describe("Uniform Dist") do

	describe("construction") do
		
		test("constructor") do
			d = GodelTest.UniformDist(-2.3, 4.22)
			@check typeof(d.distribution) == Distributions.Uniform			
			@check d.paramranges == (Float64,Float64)[]
			@check d.params == Float64[]
			@check d.distribution.a == -2.3
			@check d.distribution.b == 4.22
		end
	
		test("constructor checks") do
			@check_throws d = GodelTest.UniformDist(-2.2,-2.3) # lowerbound must be < upperbound
			@check_throws d = GodelTest.UniformDist(7.1,7.1) # lowerbound must be < upperbound
			d = GodelTest.UniformDist(0.0,0.00001)
		end

		test("constructor adjustments") do
			# adjustments as a result of constraints of underlying Distributions.Uniform
			d = GodelTest.UniformDist(-2.2,realmax(Float64)*0.50001)
			@check d.distribution.a == -2.2
			@check d.distribution.b == realmax(Float64)/2
			d = GodelTest.UniformDist(-realmax(Float64)*0.50001,2.3)
			@check d.distribution.a == -realmax(Float64)/2
			@check d.distribution.b == 2.3
			d = GodelTest.UniformDist(-realmax(Float64)/2,realmax(Float64)/2)
			@check d.distribution.a == -realmax(Float64)/2
			@check d.distribution.b == realmax(Float64)/2
		end
		
	end
	
	describe("parameters") do
	
		test("numparams") do
			d = GodelTest.UniformDist(1.2, 6.8)
			@check GodelTest.numparams(d) == 0
		end

		test("paramranges") do
		d = GodelTest.UniformDist(1.2, 6.8)
			pr = paramranges(d)
			@check typeof(pr) == Vector{(Float64,Float64)}
			@check length(pr) == 0
		end

		test("setparams") do
			d = GodelTest.UniformDist(-1.0, 1.6)
			setparams(d, Float64[])
			@check typeof(d.distribution) == Distributions.Uniform
			@check d.distribution.a == -1.0
			@check d.distribution.b == 1.6
			@check d.params == Float64[]
		end

		test("setparams checks") do
			d = GodelTest.UniformDist(-1.0,1.6)
			@check_throws setparams(d, [0.5]) # 0 parameters
		end

		test("getparams") do
			d = GodelTest.UniformDist(-1.0, 1.6)
			@check getparams(d) == Float64[]
		end

		test("supportlowerbound") do
			d = GodelTest.UniformDist(-1.2, 2.34)
			@check GodelTest.supportlowerbound(d) == -1.2
		end
		
	end

	describe("sampling") do

		d = GodelTest.UniformDist(12.4,42.0)
	
		@repeat test("across full range of support") do
			s = GodelTest.sample(d)
			@check typeof(s) == Float64
			@check 12.4 <= s <= 42.0
			@mcheck_that_sometimes s < 27.3 
			@mcheck_that_sometimes s > 27.3 
		end

	end
	
end

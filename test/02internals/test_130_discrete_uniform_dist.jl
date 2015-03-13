describe("DiscreteUniform Dist") do

	describe("construction") do
		
		test("constructor") do
			d = GodelTest.DiscreteUniformDist(1,6)
			@check typeof(d.distribution) == Distributions.DiscreteUniform
			@check d.paramranges == (Float64,Float64)[]
			@check d.params == Float64[]
			@check d.distribution.a == 1
			@check d.distribution.b == 6
		end
		
		test("constructor checks") do
			@check_throws d = GodelTest.DiscreteUniformDist(7,6) # lowerbound must be <= upperbound
			d = GodelTest.DiscreteUniformDist(6,6)
		end

		test("constructor adjustments") do
			# adjustments as a result of constraints of underlying Distributions.DiscreteUniform
			l64 = convert(Int128, typemin(Int64))
			u64 = convert(Int128, typemax(Int64))
			d = GodelTest.DiscreteUniformDist(0,u64)
			@check d.distribution.a == 0
			@check d.distribution.b == typemax(Int64)
			d = GodelTest.DiscreteUniformDist(0,u64+1)
			@check d.distribution.a == 0
			@check d.distribution.b == typemax(Int64)
			d = GodelTest.DiscreteUniformDist(l64,0)
			@check d.distribution.a == typemin(Int64)
			@check d.distribution.b == 0
			d = GodelTest.DiscreteUniformDist(l64-1,0)
			@check d.distribution.a == typemin(Int64)
			@check d.distribution.b == 0
			d = GodelTest.DiscreteUniformDist(l64,u64)
			@check d.distribution.a == typemin(Int64)+1
			@check d.distribution.b == typemax(Int64)
			d = GodelTest.DiscreteUniformDist(l64-1,u64+1)
			@check d.distribution.a == typemin(Int64)+1
			@check d.distribution.b == typemax(Int64)
		end
		
	end
	
	describe("parameters") do
	
		test("numparams") do
			d = GodelTest.DiscreteUniformDist(1,6)
			@check GodelTest.numparams(d) == 0
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
		end

		test("setparams checks") do
			d = GodelTest.DiscreteUniformDist(-10,16)
			@check_throws setparams(d, [0.5]) # 0 parameters
		end
		
		test("getparams") do
			d = GodelTest.DiscreteUniformDist(1,6)
			@check getparams(d) == Float64[]
		end
		
		test("supportlowerbound") do
			d = GodelTest.DiscreteUniformDist(-19, 23)
			@check GodelTest.supportlowerbound(d) == -19
		end
		
	end
	
	describe("sampling") do

		describe("sample") do

			d = GodelTest.DiscreteUniformDist(9,13)
	
			@repeat test("across full range of support") do
				s = GodelTest.sample(d)
				@check typeof(s) == Int64
				@mcheck_values_are s [9, 10, 11, 12, 13]
			end

		end

		describe("sample max upper") do
			
			d = GodelTest.DiscreteUniformDist(9, typemax(Int64))
			
			@repeat test("across full range of support") do
				s = GodelTest.sample(d)
				@check typeof(s) == Int64
				@check 9 <= s <= typemax(Int64)
			end

		end

		describe("sample min lower") do

			d = GodelTest.DiscreteUniformDist(typemin(Int64),10)
		
			@repeat test("across full range of support") do
				s = GodelTest.sample(d)
				@check typeof(s) == Int64
				@check typemin(Int64) <= s <= 10 # actually lower bound is typemin(Int64)+1
			end

		end

		describe("sample min lower and max upper") do

			d = GodelTest.DiscreteUniformDist(typemin(Int64),typemax(Int64))
		
			@repeat test("across full range of support") do
				s = GodelTest.sample(d)
				@check typeof(s) == Int64
				@check typemin(Int64) <= s <= typemax(Int64)
				@mcheck_that_sometimes s < 0
				@mcheck_that_sometimes s > 0
			end

		end

	end

end

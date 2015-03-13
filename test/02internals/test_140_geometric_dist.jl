describe("Geometric Dist") do

	describe("construction") do
		
		test("constructor") do
			d = GodelTest.GeometricDist()
			@check typeof(d.distribution) == Distributions.Geometric
			@check d.paramranges == [(0.0,1.0)]
			@check d.params == [0.5]
			@check d.distribution.p == 0.5
		end
		
	end
	
	describe("parameters") do
		
		test("numparams") do
			d = GodelTest.GeometricDist()
			@check GodelTest.numparams(d) == 1
		end

		test("paramranges") do
			d = GodelTest.GeometricDist()
			pr = paramranges(d)
			@check typeof(pr) == Vector{(Float64,Float64)}
			@check pr == [(0.0,1.0)]
		end

		test("setparams") do
			d = GodelTest.GeometricDist()
			setparams(d, [0.7])
			@check typeof(d.distribution) == Distributions.Geometric
			@check d.distribution.p == 0.7
			@check d.params == [0.7]
		end
		
		test("setparams checks") do
			d = GodelTest.GeometricDist()
			@check_throws setparams(d, Float64[]) # too few parameters
			@check_throws setparams(d, [0.1, 0.5]) # too many parameters
			@check_throws setparams(d, [-0.01]) # < 0
			@check_throws setparams(d, [1.01]) # >= 0
		end
		
		test("setparams adjustments") do
			d = GodelTest.GeometricDist()
			setparams(d, [1.0])
			@check 0.99999 <= d.params[1] < 1.0
			@check 0.99999 <= d.distribution.p < 1.0
			setparams(d, [0.0])
			@check 0.0 < d.params[1] <= 0.00001
			@check 0.0 < d.distribution.p <= 0.00001
		end

		test("getparams") do
			d = GodelTest.GeometricDist()
			setparams(d, [0.4])
			@check getparams(d) == [0.4]
		end
		
		test("supportlowerbound") do
			d = GodelTest.GeometricDist()
			@check GodelTest.supportlowerbound(d) == 0
		end
	
		# TODO supportlowerquartile
		
	end
	
	describe("sampling") do

		d = GodelTest.GeometricDist()

		@repeat test("across full range of support") do
			setparams(d, [0.5])
			s = GodelTest.sample(d)
			@check typeof(s) == Int64
			@mcheck_values_include s [0,1,2,3]
			@mcheck_that_sometimes s >= 6
		end

		@repeat test("with random parameters is within range of support") do
			setparams(d, [rand()])
			s = GodelTest.sample(d)
			@check typeof(s) == Int64
			@check 0 <= s
		end

	end
		
end

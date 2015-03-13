describe("Normal Dist") do

	describe("construction") do
		
		test("constructor") do
			d = GodelTest.GaussianDist()
			@check typeof(d.distribution) == Distributions.Normal
			@check d.paramranges == [(-Inf,Inf), (0.0,realmax(Float64))]
			@check d.params == [0.0, 1.0]
			@check d.distribution.μ == 0.0
			@check d.distribution.σ == 1.0
		end
		
	end
	
	describe("parameters") do
		
		test("numparams") do
			d = GodelTest.GaussianDist()
			@check GodelTest.numparams(d) == 2
		end

		test("paramranges") do
			d = GodelTest.GaussianDist()
			pr = paramranges(d)
			@check typeof(pr) == Vector{(Float64,Float64)}
			@check pr == [(-Inf,Inf), (0.0,realmax(Float64))]
		end

		test("setparams") do
			d = GodelTest.GaussianDist()
			setparams(d, [-40.0, 12.3])
			@check typeof(d.distribution) == Distributions.Normal
			@check d.distribution.μ == -40.0
			@check d.distribution.σ == 12.3
			@check d.params == [-40.0, 12.3]
		end
		
		test("setparams checks") do
			d = GodelTest.GaussianDist()
			@check_throws setparams(d, [0.0]) # too few parameters
			@check_throws setparams(d, [10.0, 12.8, -32.2]) # too many parameters
			@check_throws setparams(d, [0.0, -0.01]) # params[2]< 0
			@check_throws setparams(d, [0.0, Inf]) # params[2] > realmax(Float64)
		end
		
		test("setparams adjustments") do
			d = GodelTest.GaussianDist()
			setparams(d, [14.5, 0.0])
			@check 0.0 < d.params[2] <= 0.00001
			@check 0.0 < d.distribution.σ <= 0.00001
		end

		test("getparams") do
			d = GodelTest.GaussianDist()
			setparams(d, [423.17, 2.22])
			@check getparams(d) == [423.17, 2.22]
		end
		
		# test("supportlowerbound") do
		# 	d = GodelTest.GaussianDist()
		# 	@check GodelTest.supportlowerbound(d) == 0
		# end
	
		# TODO supportlowerquartile
		
	end
	
	describe("sampling") do

		d = GodelTest.GaussianDist()

		@repeat test("across full range of support") do
			setparams(d, [100.0, 118.2])
			s = GodelTest.sample(d)
			@check typeof(s) == Float64
			@mcheck_that_sometimes s < 0.0
			@mcheck_that_sometimes s > 200.0
		end

	end
		
end

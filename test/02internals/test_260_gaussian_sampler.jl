include("mock_choice_context.jl")

describe("Gaussian Sampler") do

	test("constructor") do
		s = GodelTest.GaussianSampler()
		@check typeof(s.dist) == GodelTest.GaussianDist
	end
	
	test("numparams") do
		s = GodelTest.GaussianSampler()
		@check GodelTest.numparams(s) == 2
	end

	test("paramranges") do
		s = GodelTest.GaussianSampler()
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		pr1 = pr[1]
		pr2 = pr[2]
		@check pr1[1] < -1e10
		@check pr2[2] > 1e10
		@check pr2[1] == 0
		@check pr2[2] > 1e10
	end

	test("getparams and default") do
		s = GodelTest.GaussianSampler()
		ps = getparams(s)
		@check typeof(ps) == Vector{Float64}
		@check ps == [0.0, 1.0]
	end

	test("setparams") do
		s = GodelTest.GaussianSampler()
		setparams(s, [-12.34, 4.2])
		@check typeof(s.dist) == GodelTest.GaussianDist
		@check getparams(s) == [-12.34, 4.2]
	end

	describe("godelnumber") do
	
		s = GodelTest.GaussianSampler()
		cc = mockCC(-Inf,Inf,Float64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Float64
			@mcheck_that_sometimes gn > 0
			@mcheck_that_sometimes gn < 0
		end
		
	end
	
	describe("parameters") do
	
		s = GodelTest.GaussianSampler()
		@repeat test("godelnumber respects choice context lower bound for random parameters") do
			setparams(s,[rand()*100-50, rand()*100])
			lowerbound = rand()*100-50
			upperbound = lowerbound+rand()*100
			cc = mockCC(lowerbound,upperbound,Float64)
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check cc.lowerbound <= gn <= upperbound
		end
	
	end
	
end

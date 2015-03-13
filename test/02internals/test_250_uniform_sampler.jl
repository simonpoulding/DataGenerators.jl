include("mock_choice_context.jl")

describe("Uniform Sampler") do

	test("constructor") do
		s = GodelTest.UniformSampler()
		@check typeof(s.dist) == GodelTest.UniformDist
	end
	
	test("numparams") do
		s = GodelTest.UniformSampler()
		@check GodelTest.numparams(s) == 0
	end

	test("paramranges") do
		s = GodelTest.UniformSampler()
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr) == 0
	end

	test("getparams and default") do
		s = GodelTest.UniformSampler()
		ps = getparams(s)
		@check typeof(ps) == Vector{Float64}
		@check ps == []
	end

	test("setparams") do
		s = GodelTest.UniformSampler()
		setparams(s, Float64[])
		@check typeof(s.dist) == GodelTest.UniformDist
		@check getparams(s) == []
	end

	describe("godelnumber") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(-3.7,1.2,Float64)
	
		@repeat test("godelnumber sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check cc.lowerbound <= gn <= cc.upperbound
		end
		
	end
	
	describe("parameters") do
		
		s = GodelTest.UniformSampler()
		@repeat test("respects choice context bounds") do
			# because a new uniform dist is created when the bounds change, this is particularly important to check over
			# a series of different bounds
			lowerbound = rand()*100-50
			upperbound = lowerbound+rand()*100
			cc = mockCC(lowerbound,upperbound,Float64)
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check cc.lowerbound <= gn <= cc.upperbound
		end
		
	end
	
	describe("godelnumber handles finite lower and infinite upper choice point bound") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(4.2,Inf,Float64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn > 1e10
		end
		
	end
	
	describe("godelnumber handles infinite lower bound and finite upper choice context bound") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(-Inf,42,Float64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn < -1e10
		end
		
	end

	describe("godelnumber handles infinite lower bound and finite upper choice context bound") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(-Inf,Inf,Float64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Float64
			@mcheck_that_sometimes gn < 0
			@mcheck_that_sometimes gn > 0
		end
		
	end
	

end

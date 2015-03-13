include("mock_choice_context.jl")

describe("DiscreteUniform Sampler") do

	test("constructor") do
		s = GodelTest.DiscreteUniformSampler()
		@check typeof(s.dist) == GodelTest.DiscreteUniformDist
	end

	test("numparams") do
		s = GodelTest.DiscreteUniformSampler()
		@check GodelTest.numparams(s) == 0
	end

	test("paramranges") do
		s = GodelTest.DiscreteUniformSampler()
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr) == 0
	end

	test("getparams and default") do
		s = GodelTest.DiscreteUniformSampler()
		ps = getparams(s)
		@check typeof(ps) == Vector{Float64}
		@check ps == []
	end

	test("setparams") do
		s = GodelTest.DiscreteUniformSampler()
		setparams(s, Float64[])
		@check typeof(s.dist) == GodelTest.DiscreteUniformDist
		@check getparams(s) == []
	end

	describe("godelnumber") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(-3,1,Int64)
	
		@repeat test("godelnumber sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@mcheck_values_are gn [-3,-2,-1,0,1]
		end
		
	end
	
	describe("parameters") do

		s = GodelTest.DiscreteUniformSampler()
		@repeat test("respects choice context bounds") do
			# because a new uniform dist is created when the bounds change, this is particularly important to check over
			# a series of different bounds
			lowerbound = floor(int(rand()*100))-50
			upperbound = lowerbound+floor(int(rand()*100))
			cc = mockCC(lowerbound,upperbound,Int64)
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
		end
		
	end
	
	describe("godelnumber handles finite lower and 'infinite' upper choice context bound") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(42,typemax(Int64),Int64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn < typemax(Int)/2
			@mcheck_that_sometimes gn > typemax(Int)/2
		end
		
	end
	
	describe("godelnumber handles 'infinite' lower bound and finite upper choice context bound") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(typemin(Int64),42,Int64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn < typemin(Int)/2
			@mcheck_that_sometimes gn > typemin(Int)/2
		end
		
	end

	describe("godelnumber handles 'infinite' lower bound and upper choice context bound") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(typemin(Int64),typemax(Int64),Int64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn < 0
			@mcheck_that_sometimes gn > 0
		end
		
	end

end

include("mock_choice_context.jl")

describe("Bernoulli Sampler") do

	test("constructor") do
		s = GodelTest.BernoulliSampler()
		@check typeof(s.dist) == GodelTest.BernoulliDist
	end
	
	test("numparams") do
		s = GodelTest.BernoulliSampler()
		@check GodelTest.numparams(s) == 1
	end

	test("paramranges") do
		s = GodelTest.BernoulliSampler()
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check length(pr)==1
		@check all(x->x==(0.0,1.0),pr)		
	end

	test("getparams and default params") do
		s = GodelTest.BernoulliSampler()
		ps = getparams(s)
		@check typeof(ps) == Vector{Float64}
		@check ps == [0.5]
	end

	test("setparams") do
		s = GodelTest.BernoulliSampler()
		setparams(s, [0.7])
		@check typeof(s.dist) == GodelTest.BernoulliDist
		@check getparams(s) == [0.7]
	end

	describe("godelnumber") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(0,1,Int64)
	
		@repeat test("GodelTest.godelnumber sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@mcheck_values_are gn [0,1]
		end
		
	end
	
	describe("random parameters") do

		s = GodelTest.BernoulliSampler()
		@repeat test("respects choice context bounds for random parameters") do
			setparams(s, [rand()])
			lowerbound = floor(int(rand()*100))-50
			upperbound = lowerbound+floor(int(rand()*100))
			cc = mockCC(lowerbound,upperbound,Int64)
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
		end

	end
	
	describe("godelnumber handles finite lower and 'infinite' upper choice context bound") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(42,typemax(Int64),Int64)
	
		@repeat test("GodelTest.godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			# @mcheck_values_are gn [cc.lowerbound, cc.lowerbound+1]
			# TODO since above requires literal values on RHS, use instead:
			@check cc.lowerbound <= gn <= (cc.lowerbound+1)
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)			
		end
		
	end

	describe("godelnumber handles 'infinite' lower and finite upper choice context bound") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(typemin(Int64),42,Int64)
	
		@repeat test("GodelTest.godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			# @mcheck_values_are gn [cc.lowerbound, cc.lowerbound+1]
			# TODO since above requires literal values on RHS, use instead:
			@check cc.lowerbound <= gn <= (cc.lowerbound+1)
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)
		end
		
	end
	
	describe("godelnumber handles 'infinite' lower and upper choice context bound") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(typemin(Int64),typemax(Int64),Int64)
	
		@repeat test("GodelTest.godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			# @mcheck_values_are gn [cc.lowerbound, cc.lowerbound+1]
			# TODO since above requires literal values on RHS, use instead:
			@check cc.lowerbound <= gn <= (cc.lowerbound+1)
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)
		end
		
	end

end

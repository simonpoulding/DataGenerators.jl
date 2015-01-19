include("mock_choice_context.jl")

describe("Bernoulli Sampler") do

	test("no params constructor") do
		s = GodelTest.BernoulliSampler()
		@check typeof(s.dist) == GodelTest.BernoulliDist
	end
	
	# TODO check num param error

	test("numparams") do
		s = GodelTest.BernoulliSampler()
		@check numparams(s) == 1
	end

	test("paramranges") do
		s = GodelTest.BernoulliSampler()
		pr = paramranges(s)
		@check length(pr)==1
		@check all(x->x==(0.0,1.0),pr)		
	end

	test("getparams and default value") do
		s = GodelTest.BernoulliSampler()
		@check getparams(s) == [0.5]
	end

	test("setparams and getparams") do
		s = GodelTest.BernoulliSampler()
		setparams(s, [0.7])
		@check typeof(s.dist) == GodelTest.BernoulliDist
		@check getparams(s) == [0.7]
	end


	test("godelnumber") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(0,1,Int)
	
		@repeat test("godelnumber sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			@mcheck_values_are gn [0,1]
		end
		
	end
	
	@repeat test("respects choice context lower bound for random parameters") do
		s = GodelTest.BernoulliSampler()
		setparams(s, [rand()])
		lowerbound = floor(int(rand()*100))-50
		upperbound = lowerbound+floor(int(rand()*100))
		cc = mockCC(lowerbound,upperbound,Int)
		gn = godelnumber(s,cc)
		@check typeof(gn) == Int
		@check cc.lowerbound <= gn
	end
	
	
	describe("godelnumber handles finite lower and 'infinite' upper choice context bound") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(42,typemax(Int),Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			# @mcheck_values_are gn [cc.lowerbound, cc.lowerbound+1]
			# TODO since above requires literal values on RHS, use instead:
			@check cc.lowerbound <= gn <= (cc.lowerbound+1)
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)			
		end
		
	end

	describe("godelnumber handles 'infinite' lower and finite upper choice context bound") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(typemin(Int),42,Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			# @mcheck_values_are gn [cc.lowerbound, cc.lowerbound+1]
			# TODO since above requires literal values on RHS, use instead:
			@check cc.lowerbound <= gn <= (cc.lowerbound+1)
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)
		end
		
	end
	
	describe("godelnumber handles 'infinite' lower and upper choice context bound") do
	
		s = GodelTest.BernoulliSampler()
		cc = mockCC(typemin(Int),typemax(Int),Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			# @mcheck_values_are gn [cc.lowerbound, cc.lowerbound+1]
			# TODO since above requires literal values on RHS, use instead:
			@check cc.lowerbound <= gn <= (cc.lowerbound+1)
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)
		end
		
	end

end

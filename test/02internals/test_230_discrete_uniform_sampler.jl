include("mock_choice_context.jl")

describe("DiscreteUniform Sampler") do

	test("no params constructor") do
		s = GodelTest.DiscreteUniformSampler()
		@check typeof(s.dist) == Distributions.DiscreteUniform
		# @check s.params == []
		@check s.nparams == 0
	end
	
	# test("params constructor") do
	# 	s = GodelTest.DiscreteUniformSampler([])
	# 	@check typeof(s.dist) == Distributions.DiscreteUniform
	# 	# @check s.params == []
	# 	@check s.nparams == 0
	# end
	
	# TODO check num param error

	test("numparams") do
		s = GodelTest.DiscreteUniformSampler()
		@check numparams(s) == 0
	end

	test("paramranges") do
		s = GodelTest.DiscreteUniformSampler()
		pr = paramranges(s)
		@check length(pr) == 0
	end

	test("setparams") do
		s = GodelTest.DiscreteUniformSampler()
		setparams(s, [])
		@check typeof(s.dist) == Distributions.DiscreteUniform
		# @check s.params == []
		# @check s.nparams == 0
	end

	# TODO check num param error

	test("getparams") do
		s = GodelTest.DiscreteUniformSampler()
		@check getparams(s) == []
	end

	describe("godelnumber") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(-3,1,Int)
	
		@repeat test("godelnumber sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			@mcheck_values_are gn [-3,-2,-1,0,1]
		end
		
	end
	
	@repeat test("respects choice context bounds") do
		s = GodelTest.DiscreteUniformSampler()
		lowerbound = floor(int(rand()*100))-50
		upperbound = lowerbound+floor(int(rand()*100))
		cc = mockCC(lowerbound,upperbound,Int)
		gn = godelnumber(s,cc)
		@check typeof(gn) == Int
		@check cc.lowerbound <= gn <= cc.upperbound
	end
	
	describe("godelnumber handles finite lower and 'infinite' upper choice context bound") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(42,typemax(Int),Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn < typemax(Int)/2
			@mcheck_that_sometimes gn > typemax(Int)/2
		end
		
	end
	
	describe("godelnumber handles 'infinite' lower bound and finite upper choice context bound") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(typemin(Int),42,Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn < typemin(Int)/2
			@mcheck_that_sometimes gn > typemin(Int)/2
		end
		
	end

	describe("godelnumber handles 'infinite' lower bound and upper choice context bound") do
	
		s = GodelTest.DiscreteUniformSampler()
		cc = mockCC(typemin(Int),typemax(Int),Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_that_sometimes gn < 0
			@mcheck_that_sometimes gn > 0
		end
		
	end

end

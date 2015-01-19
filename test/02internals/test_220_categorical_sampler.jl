include("mock_choice_context.jl")

describe("Categorical Sampler") do

	test("no params constructor") do
		s = GodelTest.CategoricalSampler(4)
		@check typeof(s.dist) == Distributions.Categorical
		@check s.params == [0.25, 0.25, 0.25, 0.25]
		@check s.nparams == 4
	end
	
	test("params constructor") do
		s = GodelTest.CategoricalSampler(3,[0.3, 0.2, 0.5])
		@check typeof(s.dist) == Distributions.Categorical
		@check s.params == [0.3, 0.2, 0.5]
		@check s.nparams == 3
	end

	# TODO check num param error

	test("numparams") do
		s = GodelTest.CategoricalSampler(7,[0.1, 0.2, 0.1, 0.1, 0.1, 0.2, 0.2])
		@check numparams(s) == 7
	end

	test("paramranges") do
		s = GodelTest.CategoricalSampler(13)
		pr = paramranges(s)
		@check length(pr)==13
		@check all(x->x==(0.0, 1.0),pr)
	end

	test("setparams") do
		s = GodelTest.CategoricalSampler(3,[0.4, 0.4, 0.2])
		setparams(s, [0.7, 0.1, 0.2])
		@check typeof(s.dist) == Distributions.Categorical
		@check s.params == [0.7, 0.1, 0.2]
		@check s.nparams == 3
	end

	# TODO check num param error

	test("invalid parameters are adjusted") do
		s = GodelTest.CategoricalSampler(4)
		setparams(s,[0.2, 0.1, 0.1, 0.1])
		@check s.params == [0.4, 0.2, 0.2, 0.2]
		setparams(s,[0.5, 1.0, 0.5, 0.0])
		@check s.params == [0.25, 0.5, 0.25, 0.0]
		setparams(s,[0.0, 0.0, 0.0, 0.0])
		@check s.params == [0.25, 0.25, 0.25, 0.25]
	end

	test("getparams") do
		s = GodelTest.CategoricalSampler(2,[0.4, 0.6])
		@check getparams(s) == [0.4, 0.6]
	end

	describe("godelnumber") do

		s = GodelTest.CategoricalSampler(4)
		cc = mockCC(1,4,Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			@mcheck_values_are gn [1,2,3,4]
		end
		
	end
	
	
	@repeat test("respects choice context lower bound for random parameters") do
		s = GodelTest.CategoricalSampler(3, [rand(), rand(), rand()])
		lowerbound = floor(int(rand()*100))-50
		upperbound = lowerbound+floor(int(rand()*100))
		cc = mockCC(lowerbound,upperbound,Int)
		gn = godelnumber(s,cc)
		@check typeof(gn) == Int
		@check cc.lowerbound <= gn
	end
	
	
	# describe("godelnumber handles finite lower and 'infinite' upper choice context bound") do
	#
	# 	s = GodelTest.CategoricalSampler(5)
	# 	cc = mockCC(42,typemax(Int),Int)
	#
	# 	@repeat test("godelnumbers sampled across full range of support") do
	# 		gn = godelnumber(s,cc)
	# 		@check typeof(gn) == Int
	# 		# @mcheck_values_are gn [cc.lowerbound + i for i in 0:4]
	# 		# @mcheck_values_are gn [cc.lowerbound + i for i in 0:4]
	# 		# TODO since above requires literal values on RHS, use instead:
	# 		@check cc.lowerbound <= gn <= (cc.lowerbound+4)
	# 		@mcheck_that_sometimes gn == cc.lowerbound
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+1)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+2)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+3)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+4)
	# 	end
	#
	# end
	#
	# describe("godelnumber handles 'infinite' lower bound and finite upper choice context bound") do
	#
	# 	s = GodelTest.CategoricalSampler(5)
	# 	cc = mockCC(typemin(Int),42,Int)
	#
	# 	@repeat test("godelnumbers sampled across full range of support") do
	# 		gn = godelnumber(s,cc)
	# 		@check typeof(gn) == Int
	# 		# @mcheck_values_are gn [cc.lowerbound + i for i in 0:4]
	# 		# TODO since above requires literal values on RHS, use instead:
	# 		@check cc.lowerbound <= gn <= (cc.lowerbound+4)
	# 		@mcheck_that_sometimes gn == cc.lowerbound
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+1)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+2)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+3)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+4)
	# 	end
	#
	# end
	#
	# describe("godelnumber handles 'infinite' lower bound and upper choice context bound") do
	#
	# 	s = GodelTest.CategoricalSampler(5)
	# 	cc = mockCC(typemin(Int),typemax(Int),Int)
	#
	# 	@repeat test("godelnumbers sampled across full range of support") do
	# 		gn = godelnumber(s,cc)
	# 		@check typeof(gn) == Int
	# 		# @mcheck_values_are gn [cc.lowerbound + i for i in 0:4]
	# 		# @mcheck_values_are gn [cc.lowerbound + i for i in 0:4]
	# 		# TODO since above requires literal values on RHS, use instead:
	# 		@check cc.lowerbound <= gn <= (cc.lowerbound+4)
	# 		@mcheck_that_sometimes gn == cc.lowerbound
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+1)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+2)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+3)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+4)
	# 	end
	#
	# end

	# TODO fallback
	
end

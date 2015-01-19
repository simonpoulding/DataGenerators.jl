include("mock_choice_context.jl")

describe("Geometric Sampler") do

	test("no params constructor") do
		s = GodelTest.GeometricSampler()
		@check typeof(s.dist) == Distributions.Geometric
		@check s.params == [0.5]
		@check s.nparams == 1
	end
	
	test("params constructor") do
		s = GodelTest.GeometricSampler([0.3])
		@check typeof(s.dist) == Distributions.Geometric
		@check s.params == [0.3]
		@check s.nparams == 1
	end

	# TODO check num param error

	test("numparams") do
		s = GodelTest.GeometricSampler([0.1])
		@check numparams(s) == 1
	end

	test("paramranges") do
		s = GodelTest.GeometricSampler([0.9])
		pr = paramranges(s)
		@check length(pr)==1
		@check all(x->x==(0.0,1.0),pr)
	end

	test("setparams") do
		s = GodelTest.GeometricSampler([0.3])
		setparams(s, [0.7])
		@check typeof(s.dist) == Distributions.Geometric
		@check s.params == [0.7]
		@check s.nparams == 1	
	end

	# TODO check num param error

	test("invalid parameters are adjusted") do
		s = GodelTest.GeometricSampler()
		setparams(s,[1.1])
		@check 0.99 <= s.params[1] < 1.0
		setparams(s,[1.0])
		@check 0.99 <= s.params[1] < 1.0
		setparams(s,[-0.0])
		@check 0.0 < s.params[1] <= 0.01
		setparams(s,[-0.2])
		@check 0.0 < s.params[1] <= 0.01
	end

	test("getparams") do
		s = GodelTest.GeometricSampler([0.4])
		@check getparams(s) == [0.4]
	end

	describe("godelnumber") do
	
		s = GodelTest.GeometricSampler()
		cc = mockCC(0,1,Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Int
			@mcheck_values_include gn [0,1,2,3]
			@mcheck_that_sometimes gn >= 6
		end
		
	end
	
	@repeat test("godelnumber respects choice context lower bound for random parameters") do
		s = GodelTest.GeometricSampler([rand()])
		lowerbound = floor(int(rand()*100))-50
		upperbound = lowerbound+floor(int(rand()*100))
		cc = mockCC(lowerbound,upperbound,Int)
		gn = godelnumber(s,cc)
		@check typeof(gn) == Int
		@check cc.lowerbound <= gn
	end
	
	# describe("godelnumber handles finite lower and 'infinite' upper choice context bound") do
	#
	# 	s = GodelTest.GeometricSampler()
	# 	cc = mockCC(42,typemax(Int),Int)
	#
	# 	@repeat test("godelnumbers sampled across full range of support") do
	# 		gn = godelnumber(s,cc)
	# 		@check typeof(gn) == Int
	# 		@check cc.lowerbound <= gn
	# 		# @mcheck_values_include gn [cc.lowerbound + i for i in 0:3]
	# 		# TODO since above requires literal values on RHS, use instead:
	# 		@mcheck_that_sometimes gn == cc.lowerbound
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+1)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+2)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+3)
	# 		@mcheck_that_sometimes gn >= (cc.lowerbound+6)
	# 	end
	#
	# end
	#
	# describe("godelnumber handles 'infinite' lower and finite upper choice context bound") do
	#
	# 	s = GodelTest.GeometricSampler()
	# 	cc = mockCC(typemin(Int),42,Int)
	#
	# 	@repeat test("godelnumbers sampled across full range of support") do
	# 		gn = godelnumber(s,cc)
	# 		@check typeof(gn) == Int
	# 		@check cc.lowerbound <= gn
	# 		# @mcheck_values_include gn [cc.lowerbound + i for i in 0:3]
	# 		# TODO since above requires literal values on RHS, use instead:
	# 		@mcheck_that_sometimes gn == cc.lowerbound
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+1)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+2)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+3)
	# 		@mcheck_that_sometimes gn >= (cc.lowerbound+6)
	# 	end
	#
	# end
	#
	# describe("godelnumber handles 'infinite' lower and upper choice context bound") do
	#
	# 	s = GodelTest.GeometricSampler()
	# 	cc = mockCC(typemin(Int),typemax(Int),Int)
	#
	# 	@repeat test("godelnumbers sampled across full range of support") do
	# 		gn = godelnumber(s,cc)
	# 		@check typeof(gn) == Int
	# 		@check cc.lowerbound <= gn
	# 		# @mcheck_values_include gn [cc.lowerbound + i for i in 0:3]
	# 		# TODO since above requires literal values on RHS, use instead:
	# 		@mcheck_that_sometimes gn == cc.lowerbound
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+1)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+2)
	# 		@mcheck_that_sometimes gn == (cc.lowerbound+3)
	# 		@mcheck_that_sometimes gn >= (cc.lowerbound+6)
	#
	# 	end
	#
	# end

	# TODO: fallback
	
end

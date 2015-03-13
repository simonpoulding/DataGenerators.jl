include("mock_choice_context.jl")

describe("Geometric Sampler") do

	test("constructor") do
		s = GodelTest.GeometricSampler()
		@check typeof(s.dist) == GodelTest.GeometricDist
	end
	
	test("numparams") do
		s = GodelTest.GeometricSampler()
		@check GodelTest.numparams(s) == 1
	end

	test("paramranges") do
		s = GodelTest.GeometricSampler()
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check pr == [(0.0,1.0)]
	end

	test("getparams and default") do
		s = GodelTest.GeometricSampler()
		ps = getparams(s)
		@check typeof(ps) == Vector{Float64}
		@check ps == [0.5]
	end

	test("setparams") do
		s = GodelTest.GeometricSampler()
		setparams(s, [0.7])
		@check typeof(s.dist) == GodelTest.GeometricDist
		@check getparams(s) == [0.7]
	end

	describe("godelnumber") do
	
		s = GodelTest.GeometricSampler()
		cc = mockCC(0,typemax(Int),Int)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@mcheck_values_include gn [0,1,2,3]
			@mcheck_that_sometimes gn >= 6
		end
		
	end
	
	describe("parameters") do
	
		s = GodelTest.GeometricSampler()
		@repeat test("godelnumber respects choice context lower bound for random parameters") do
			setparams(s,[rand()])
			lowerbound = floor(int(rand()*100))-50
			upperbound = lowerbound+floor(int(rand()*100))
			cc = mockCC(lowerbound,upperbound,Int64)
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= upperbound
		end
	
	end
	
	describe("godelnumber handles finite lower and 'infinite' upper choice context bound") do

		s = GodelTest.GeometricSampler()
		cc = mockCC(42,typemax(Int64),Int64)

		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			# @mcheck_values_include gn [cc.lowerbound + i for i in 0:3]
			# TODO since above requires literal values on RHS, use instead:
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)
			@mcheck_that_sometimes gn == (cc.lowerbound+2)
			@mcheck_that_sometimes gn == (cc.lowerbound+3)
			@mcheck_that_sometimes gn >= (cc.lowerbound+6)
		end

	end

	describe("godelnumber handles 'infinite' lower and finite upper choice context bound") do

		s = GodelTest.GeometricSampler()
		cc = mockCC(typemin(Int64),42,Int64)

		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			# @mcheck_values_include gn [cc.lowerbound + i for i in 0:3]
			# TODO since above requires literal values on RHS, use instead:
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)
			@mcheck_that_sometimes gn == (cc.lowerbound+2)
			@mcheck_that_sometimes gn == (cc.lowerbound+3)
			@mcheck_that_sometimes gn >= (cc.lowerbound+6)
		end

	end

	describe("godelnumber handles 'infinite' lower and upper choice context bound") do

		s = GodelTest.GeometricSampler()
		cc = mockCC(typemin(Int64),typemax(Int64),Int64)

		@repeat test("godelnumbers sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			# @mcheck_values_include gn [cc.lowerbound + i for i in 0:3]
			# TODO since above requires literal values on RHS, use instead:
			@mcheck_that_sometimes gn == cc.lowerbound
			@mcheck_that_sometimes gn == (cc.lowerbound+1)
			@mcheck_that_sometimes gn == (cc.lowerbound+2)
			@mcheck_that_sometimes gn == (cc.lowerbound+3)
			@mcheck_that_sometimes gn >= (cc.lowerbound+6)

		end

	end

end

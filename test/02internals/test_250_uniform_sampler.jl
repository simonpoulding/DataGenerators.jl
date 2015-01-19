include("mock_choice_context.jl")

describe("Uniform Sampler") do

	test("no params constructor") do
		s = GodelTest.UniformSampler()
		@check typeof(s.dist) == Distributions.Uniform
		# @check s.params == []
		@check s.nparams == 0
	end
	
	# test("params constructor") do
	# 	s = GodelTest.UniformSampler([])
	# 	@check typeof(s.dist) == Distributions.Uniform
	# 	# @check s.params == []
	# 	@check s.nparams == 0
	# end
	
	# TODO check num param error

	test("numparams") do
		s = GodelTest.UniformSampler()
		@check numparams(s) == 0
	end

	test("paramranges") do
		s = GodelTest.UniformSampler()
		pr = paramranges(s)
		@check length(pr) == 0
	end

	test("setparams") do
		s = GodelTest.UniformSampler()
		setparams(s, [])
		@check typeof(s.dist) == Distributions.Uniform
		# @check s.params == []
		# @check s.nparams == 0
	end

	# TODO check num param error

	test("getparams") do
		s = GodelTest.UniformSampler()
		@check getparams(s) == []
	end

	describe("godelnumber") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(-3.7,1.2,Float64)
	
		@repeat test("godelnumber sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check cc.lowerbound <= gn <= cc.upperbound
		end
		
	end
	
	@repeat test("respects choice context bounds") do
		s = GodelTest.UniformSampler()
		lowerbound = rand()*100-50
		upperbound = lowerbound+rand()*100
		cc = mockCC(lowerbound,upperbound,Float64)
		gn = godelnumber(s,cc)
		@check typeof(gn) == Float64
		@check cc.lowerbound <= gn <= cc.upperbound
	end
	
	describe("godelnumber handles finite lower and infinite upper choice point bound") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(4.2,Inf,Float64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check cc.lowerbound <= gn
			@mcheck_that_sometimes gn > 1e10
		end
		
	end
	
	describe("godelnumber handles infinite lower bound and finite upper choice context bound") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(-Inf,42,Float64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Float64
			@check gn <= cc.upperbound
			@mcheck_that_sometimes gn < -1e10
		end
		
	end

	describe("godelnumber handles infinite lower bound and finite upper choice context bound") do
	
		s = GodelTest.UniformSampler()
		cc = mockCC(-Inf,Inf,Float64)
	
		@repeat test("godelnumbers sampled across full range of support") do
			gn = godelnumber(s,cc)
			@check typeof(gn) == Float64
			@mcheck_that_sometimes gn < 0
			@mcheck_that_sometimes gn > 0
		end
		
	end
	

end

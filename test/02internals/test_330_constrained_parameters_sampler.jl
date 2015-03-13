include("mock_choice_context.jl")

describe("Constrained Parameters Sampler") do

	test("constructor") do
		s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(100.0,200.0),(12.3,87.4)])
		@check getparams(s) == [100.0, 12.3] # params should be adjust to fit constraints (move to nearest bound if outside range) - default for GaussianSampler is [0.0,1.0]
		s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(-32.0,-16.0),(0.1,0.2)])
		@check getparams(s) == [-16.0, 0.2] # params should be adjust to fit constraints (move to nearest bound if outside range) - default for GaussianSampler is [0.0,1.0]
		@check_throws s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(100.0,200.0)]) # too few params
		@check_throws s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(100.0,200.0),(12.3, 87.4),(0.0,1.0)]) # too many params
		@check_throws s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(100.0,200.0),(-12.3, 87.4)]) # outside subparams range		
		@check_throws s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(100.0,200.0),(90.3,87.4)]) # lower bound is not less than or equal to upper bound
	end
	

	test("numparams") do
		ss = GodelTest.CategoricalSampler(5)
		s = GodelTest.ConstrainedParametersSampler(ss,[(0.1,0.9),(0.1,0.9),(0.1,0.9),(0.1,0.9),(0.1,0.9)])
		@check GodelTest.numparams(s) == 5
	end

	test("paramranges") do
		s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(100.0,200.0),(12.3, 87.4)])
		pr = paramranges(s)
		@check typeof(pr) == Vector{(Float64,Float64)}
		@check pr == [(100.0,200.0),(12.3, 87.4)]
	end 

	test("getparams and default") do
		ss = GodelTest.CategoricalSampler(5)
		s = GodelTest.ConstrainedParametersSampler(ss,[(0.1,0.9),(0.1,0.9),(0.1,0.9),(0.1,0.9),(0.1,0.9)])
		ps = getparams(s)
		@check typeof(ps) == Vector{Float64}
		@check ps == getparams(ss)
	end

	test("setparams") do
		
		s = GodelTest.ConstrainedParametersSampler(GodelTest.GaussianSampler(),[(100.0,200.0),(12.3, 87.4)])
		setparams(s, [137.37, 50.1])
		@check getparams(s) == [137.37, 50.1]
		setparams(s, [100.0, 50.1])
		@check_throws setparams(s, [99.999, 50.1])
		setparams(s, [200.0, 50.1])
		@check_throws setparams(s, [200.001, 50.1])
		setparams(s, [137.37, 12.3])
		@check_throws setparams(s, [137.37, 12.299])
		setparams(s, [137.37, 87.4])
		@check_throws setparams(s, [137.37, 87.401])
	end

	describe("godelnumber") do
	
		ss = GodelTest.CategoricalSampler(5)
		s = GodelTest.ConstrainedParametersSampler(ss,[(0.1,0.9),(0.1,0.9),(0.1,0.9),(0.1,0.9),(0.1,0.9)])
		cc = mockCC(1,5,Int64)
	
		@repeat test("godelnumber sampled across full range of support") do
			gn = GodelTest.godelnumber(s,cc)
			@check typeof(gn) == Int64
			@check cc.lowerbound <= gn <= cc.upperbound
			@mcheck_values_are gn [1,2,3,4,5]
		end
		
	end
	
end

include("sampler_test_utils.jl")

describe("Uniform Sampler") do
	
	describe("default construction") do

		s = GodelTest.UniformSampler()

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == 2
			prs = GodelTest.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == [(-realmax(Float64), realmax(Float64)), (-realmax(Float64), realmax(Float64))]
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == [-1.0, 1.0]
			@check isconsistentuniform(s, GodelTest.getparams(s))
		end
	
		@repeat test("default sampling") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Float64
			@check -1.0 <= x <= 1.0
		end
	end
			
	describe("non-default construction") do

		s = GodelTest.UniformSampler([-100.7,129.3762])
		
		test("constructor with params") do
			@check GodelTest.getparams(s) == [-100.7,129.3762]
			@check isconsistentuniform(s, GodelTest.getparams(s))
		end
		
	end
	
	describe("parameter setting") do
		
		s = GodelTest.UniformSampler()
		prs = GodelTest.paramranges(s)
		midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

		test("setparams with wrong number of parameters") do
			@check_throws GodelTest.setparams(s, midparams[1:end-1])
			@check_throws GodelTest.setparams(s, [midparams, 0.5])
		end

		test("setparams boundary values") do
			for pidx = 1:length(prs)
				pr = prs[pidx]
				params = copy(midparams)
				params[pidx] = pr[1] 
				GodelTest.setparams(s, params)
				@check isconsistentuniform(s, params)
				params[pidx] = prevfloat(pr[1])
				@check_throws GodelTest.setparams(s, params)
				params[pidx] = pr[2] 
				GodelTest.setparams(s, params)
				@check isconsistentuniform(s, params)
				params[pidx] = nextfloat(pr[2])
				@check_throws GodelTest.setparams(s, params)
			end
		end
	
		test("setparams adjusts order of bounds") do
			GodelTest.setparams(s, [50.23,8.4])
			@check GodelTest.getparams(s) == [8.4,50.23]
			@check isconsistentuniform(s, GodelTest.getparams(s))
		end

		test("setparams handles full Float64 range bounds") do
			params = [-realmax(Float64), realmax(Float64)]
			GodelTest.setparams(s, params)
			@check isconsistentuniform(s, params)
		end

		@repeat test("setparams with random parameters") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			GodelTest.setparams(s, params)
			@check isconsistentuniform(s, params)
		end

		@repeat test("setparams with realistic random parameters") do
			params = [rand() * 2e6 - 1e6, rand() * 2e6 - 1e6]
			GodelTest.setparams(s, params)
			@check isconsistentuniform(s, params)
		end

	end
	
	describe("lower bound equals upper bound") do

		s = GodelTest.UniformSampler()
		params = [0.712, 0.712]
		
		test("setparams handles equal params") do
			GodelTest.setparams(s, params)
			GodelTest.getparams(s) == params
		end

		@repeat test("equal lower and upper bounds") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Float64
			@check x == 0.712
		end
		
	end
	
	describe("samples boundaries of support") do

		s = GodelTest.UniformSampler()
		params = [87.23, nextfloat(nextfloat(87.23))]
		GodelTest.setparams(s, params)

		@repeat test("samples end points of param range") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Float64
			@mcheck_values_are x [87.23, nextfloat(87.23), nextfloat(nextfloat(87.23))]
		end
		
	end
	
	describe("estimate parameters") do
		
		s = GodelTest.UniformSampler()
		prs = GodelTest.paramranges(s)
		otherparams = [-42.9, 42.2]
		
		test("non-equal bounds") do
			params = [20.55, 29.12]
			s1 = GodelTest.UniformSampler(params)
			s2 = GodelTest.UniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentuniform(s2, params)
		end

		test("equal bounds") do
			params = [50.22, 50.22]
			s1 = GodelTest.UniformSampler(params)
			s2 = GodelTest.UniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentuniform(s2, params)
		end

		test("random params") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			s1 = GodelTest.UniformSampler(params)
			s2 = GodelTest.UniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentuniform(s2, params)
		end

		test("equal bounds param is estimated") do
			# necessary because special handling of equal bound sets type of s.distribution to a number rather than an instance of Uniform
			params = [-2.4, -2.4]
			s1 = GodelTest.UniformSampler(otherparams)
			s2 = GodelTest.UniformSampler(params)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			@check isconsistentuniform(s2, otherparams)
		end
		
		test("too few traces") do
			params = [1.1, 6.0]
			s1 = GodelTest.UniformSampler(params)
			s2 = GodelTest.UniformSampler(otherparams)	
			traces = map(1:0) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			@check isconsistentuniform(s2, otherparams)
		end
		
	end
	
end

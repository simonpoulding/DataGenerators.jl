include("sampler_test_utils.jl")

describe("Uniform Sampler") do
	
	describe("default construction") do

		s = DataGenerators.UniformSampler()

		test("numparams and paramranges") do
			@check DataGenerators.numparams(s) == 2
			prs = DataGenerators.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == [(-realmax(Float64), realmax(Float64)), (-realmax(Float64), realmax(Float64))]
		end
	
		test("default params") do
			@check DataGenerators.getparams(s) == [-1.0, 1.0]
			@check isconsistentuniform(s, DataGenerators.getparams(s))
		end
	
		@repeat test("default sampling") do
			x, trace = DataGenerators.sample(s, (0,1))
			@check typeof(x) <: Float64
			@check -1.0 <= x <= 1.0
		end
	end
			
	describe("non-default construction") do

		s = DataGenerators.UniformSampler([-100.7,129.3762])
		
		test("constructor with params") do
			@check DataGenerators.getparams(s) == [-100.7,129.3762]
			@check isconsistentuniform(s, DataGenerators.getparams(s))
		end
		
	end
	
	describe("parameter setting") do
		
		s = DataGenerators.UniformSampler()
		prs = DataGenerators.paramranges(s)
		midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

		test("setparams with wrong number of parameters") do
			@check_throws DataGenerators.setparams(s, midparams[1:end-1])
			@check_throws DataGenerators.setparams(s, [midparams, 0.5])
		end

		test("setparams boundary values") do
			for pidx = 1:length(prs)
				pr = prs[pidx]
				params = copy(midparams)
				params[pidx] = pr[1] 
				DataGenerators.setparams(s, params)
				@check isconsistentuniform(s, params)
				params[pidx] = prevfloat(pr[1])
				@check_throws DataGenerators.setparams(s, params)
				params[pidx] = pr[2] 
				DataGenerators.setparams(s, params)
				@check isconsistentuniform(s, params)
				params[pidx] = nextfloat(pr[2])
				@check_throws DataGenerators.setparams(s, params)
			end
		end
	
		test("setparams adjusts order of bounds") do
			DataGenerators.setparams(s, [50.23,8.4])
			@check DataGenerators.getparams(s) == [8.4,50.23]
			@check isconsistentuniform(s, DataGenerators.getparams(s))
		end

		test("setparams handles full Float64 range bounds") do
			params = [-realmax(Float64), realmax(Float64)]
			DataGenerators.setparams(s, params)
			@check isconsistentuniform(s, params)
		end

		@repeat test("setparams with random parameters") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			DataGenerators.setparams(s, params)
			@check isconsistentuniform(s, params)
		end

		@repeat test("setparams with realistic random parameters") do
			params = [rand() * 2e6 - 1e6, rand() * 2e6 - 1e6]
			DataGenerators.setparams(s, params)
			@check isconsistentuniform(s, params)
		end

	end
	
	describe("lower bound equals upper bound") do

		s = DataGenerators.UniformSampler()
		params = [0.712, 0.712]
		
		test("setparams handles equal params") do
			DataGenerators.setparams(s, params)
			DataGenerators.getparams(s) == params
		end

		@repeat test("equal lower and upper bounds") do
			x, trace = DataGenerators.sample(s, (0,1))
			@check typeof(x) <: Float64
			@check x == 0.712
		end
		
	end
	
	describe("samples boundaries of support") do

		s = DataGenerators.UniformSampler()
		params = [87.23, nextfloat(nextfloat(87.23))]
		DataGenerators.setparams(s, params)

		@repeat test("samples end points of param range") do
			x, trace = DataGenerators.sample(s, (0,1))
			@check typeof(x) <: Float64
			@mcheck_values_are x [87.23, nextfloat(87.23), nextfloat(nextfloat(87.23))]
		end
		
	end
	
	describe("estimate parameters") do
		
		s = DataGenerators.UniformSampler()
		prs = DataGenerators.paramranges(s)
		otherparams = [-42.9, 42.2]
		
		test("non-equal bounds") do
			params = [20.55, 29.12]
			s1 = DataGenerators.UniformSampler(params)
			s2 = DataGenerators.UniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentuniform(s2, params)
		end

		test("equal bounds") do
			params = [50.22, 50.22]
			s1 = DataGenerators.UniformSampler(params)
			s2 = DataGenerators.UniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentuniform(s2, params)
		end

		test("random params") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			s1 = DataGenerators.UniformSampler(params)
			s2 = DataGenerators.UniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentuniform(s2, params)
		end

		test("equal bounds param is estimated") do
			# necessary because special handling of equal bound sets type of s.distribution to a number rather than an instance of Uniform
			params = [-2.4, -2.4]
			s1 = DataGenerators.UniformSampler(otherparams)
			s2 = DataGenerators.UniformSampler(params)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			@check isconsistentuniform(s2, otherparams)
		end
		
		test("too few traces") do
			params = [1.1, 6.0]
			s1 = DataGenerators.UniformSampler(params)
			s2 = DataGenerators.UniformSampler(otherparams)	
			traces = map(1:0) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			@check isconsistentuniform(s2, otherparams)
		end
		
	end
	
end

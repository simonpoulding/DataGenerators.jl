include("sampler_test_utils.jl")

describe("Discrete Uniform Sampler") do

	describe("default construction") do
		
		s = GodelTest.DiscreteUniformSampler()

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == 2
			prs = GodelTest.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == fill((float64(typemin(Int)), float64(typemax(Int))), 2)
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == [float64(typemin(Int16)), float64(typemax(Int16))]
			@check isconsistentdiscreteuniform(s, GodelTest.getparams(s))
		end
	
		@repeat test("default sampling") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Int
			@check typemin(Int16) <= x <= typemax(Int16)
		end
	
	end
	
	describe("non-default construction") do

		s = GodelTest.DiscreteUniformSampler([-100.0,129.0])
	
		test("constructor with params") do
			@check GodelTest.getparams(s) == [-100.0,129.0]
			@check isconsistentdiscreteuniform(s, GodelTest.getparams(s))
		end
		
	end
	
	describe("parameter setting") do
	
		s = GodelTest.DiscreteUniformSampler()
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
				@check isconsistentdiscreteuniform(s, params)
				params[pidx] = prevfloat(pr[1])
				@check_throws GodelTest.setparams(s, params)
				params[pidx] = pr[2]
				GodelTest.setparams(s, params)
				@check isconsistentdiscreteuniform(s, params)
				params[pidx] = nextfloat(pr[2])
				@check_throws GodelTest.setparams(s, params)
			end
		end

		test("setparams adjusts order of parameters") do
			GodelTest.setparams(s, [50.0,8.0])
			@check GodelTest.getparams(s) == [8.0,50.0]
			@check isconsistentdiscreteuniform(s, GodelTest.getparams(s))
		end

		test("setparams handles full Int range") do
			params = [float64(typemin(Int)), float64(typemax(Int))]
			GodelTest.setparams(s, params)
			@check isconsistentdiscreteuniform(s, params)
		end

		@repeat test("setparams with random parameters") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			GodelTest.setparams(s, params)
			@check isconsistentdiscreteuniform(s, params)
		end
	
	end
	
	describe("estimate parameters") do
		
		s = GodelTest.DiscreteUniformSampler()
		prs = GodelTest.paramranges(s)
		otherparams = [-42.0, 42.0]
		
		test("non-equal bounds") do
			params = [20.0, 29.0]
			s1 = GodelTest.DiscreteUniformSampler(params)
			s2 = GodelTest.DiscreteUniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentdiscreteuniform(s2, params)
		end

		test("equal bounds") do
			params = [50.0, 50.0]
			s1 = GodelTest.DiscreteUniformSampler(params)
			s2 = GodelTest.DiscreteUniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentdiscreteuniform(s2, params)
		end

		test("random params") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			s1 = GodelTest.DiscreteUniformSampler(params)
			s2 = GodelTest.DiscreteUniformSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentdiscreteuniform(s2, params)
		end
		
		test("too few traces") do
			params = [1.0, 6.0]
			s1 = GodelTest.DiscreteUniformSampler(params)
			s2 = GodelTest.DiscreteUniformSampler(otherparams)	
			traces = map(1:0) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			@check isconsistentdiscreteuniform(s2, otherparams)
		end
		
	end
		
end

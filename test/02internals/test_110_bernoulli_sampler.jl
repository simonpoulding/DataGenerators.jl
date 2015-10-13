include("sampler_test_utils.jl")

describe("Bernoulli Sampler") do

	describe("default construction") do
		
		s = GodelTest.BernoulliSampler()

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == 1
			prs = GodelTest.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == [(0.0,1.0)]
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == [0.5]
			@check isconsistentbernoulli(s, GodelTest.getparams(s))
		end
	
		@repeat test("default sampling") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Int
			@mcheck_values_are x [0,1]
		end
		
	end
	
	describe("non-default construction") do

		s = GodelTest.BernoulliSampler([0.3])
	
		test("constructor with params") do
			@check GodelTest.getparams(s) == [0.3]
			@check isconsistentbernoulli(s, GodelTest.getparams(s))
		end
		
	end
	
	describe("parameter setting") do
	
		s = GodelTest.BernoulliSampler()
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
				@check isconsistentbernoulli(s, params)
				params[pidx] = prevfloat(pr[1])
				@check_throws GodelTest.setparams(s, params)
				params[pidx] = pr[2] 
				GodelTest.setparams(s, params)
				@check isconsistentbernoulli(s, params)
				params[pidx] = nextfloat(pr[2])
				@check_throws GodelTest.setparams(s, params)
			end
		end

		@repeat test("setparams with random parameters") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			GodelTest.setparams(s, params)
			@check isconsistentbernoulli(s, params)
		end
		
	end
	
	describe("estimate parameters") do
		
		s = GodelTest.BernoulliSampler()
		prs = GodelTest.paramranges(s)
		otherparams = [0.5]
		
		test("lower bound") do
			params = [0.0]
			s1 = GodelTest.BernoulliSampler(params)
			s2 = GodelTest.BernoulliSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentbernoulli(s2, params)
		end

		test("upper bound") do
			params = [1.0]
			s1 = GodelTest.BernoulliSampler(params)
			s2 = GodelTest.BernoulliSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentbernoulli(s2, params)
		end

		test("random params") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			s1 = GodelTest.BernoulliSampler(params)
			s2 = GodelTest.BernoulliSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentbernoulli(s2, params)
		end
		
		test("too few traces") do
			params = [0.2]
			s1 = GodelTest.BernoulliSampler(params)
			s2 = GodelTest.BernoulliSampler(otherparams)	
			traces = map(1:0) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			@check isconsistentbernoulli(s2, otherparams)
		end
		
	end
		
end
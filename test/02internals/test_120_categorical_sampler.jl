include("sampler_test_utils.jl")

describe("Categorical Sampler") do

	describe("default construction") do

		s = GodelTest.CategoricalSampler(4)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == 4
			prs = GodelTest.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == fill((0.0,1.0), GodelTest.numparams(s))
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == [0.25, 0.25, 0.25, 0.25]
			@check isconsistentcategorical(s, GodelTest.getparams(s))
		end
	
		@repeat test("default sampling") do
			x, trace = GodelTest.sample(s, (0,1))
			@check typeof(x) <: Int
			@mcheck_values_are x [1,2,3,4]
		end
		
	end
		
	describe("non-default construction") do

		s = GodelTest.CategoricalSampler(5, [0.3,0.2,0.1,0.2,0.2])
		
		test("constructor with params") do
			@check getparams(s) == [0.3,0.2,0.1,0.2,0.2]
			@check isconsistentcategorical(s, GodelTest.getparams(s))
		end

	end
	
	describe("parameter setting") do
	
		s = GodelTest.CategoricalSampler(4)
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
				@check isconsistentcategorical(s, params)
				params[pidx] = prevfloat(pr[1])
				@check_throws GodelTest.setparams(s, params)
				params[pidx] = pr[2] 
				GodelTest.setparams(s, params)
				@check isconsistentcategorical(s, params)
				params[pidx] = nextfloat(pr[2])
				@check_throws GodelTest.setparams(s, params)
			end
		end
	
		test("setparams normalises weights") do
			GodelTest.setparams(s, [0.4, 0.6, 0.7, 0.3])
			@check getparams(s) == [0.2, 0.3, 0.35, 0.15]
			@check isconsistentcategorical(s, GodelTest.getparams(s))
		end
	
		test("setparams adjusts when all weights are zero") do
			GodelTest.setparams(s, [0.0, 0.0, 0.0, 0.0])
			@check getparams(s) == [0.25, 0.25, 0.25, 0.25]
			@check isconsistentcategorical(s, GodelTest.getparams(s))
		end

		@repeat test("setparams with random parameters") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			GodelTest.setparams(s, params)
			@check isconsistentcategorical(s, params)
		end
		
	end
	
	describe("estimate parameters") do
		
		s = GodelTest.CategoricalSampler(5)
		prs = GodelTest.paramranges(s)
		otherparams = [0.35, 0.15, 0.1, 0.25, 0.15]
		
		test("equal bounds") do
			params = [0.2, 0.2, 0.2, 0.2, 0.2]
			s1 = GodelTest.CategoricalSampler(5, params)
			s2 = GodelTest.CategoricalSampler(5, otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentcategorical(s2, params)
		end

		test("last category never sampled") do
			params = [0.3, 0.4, 0.2, 0.1, 0.0]
			s1 = GodelTest.CategoricalSampler(5, params)
			s2 = GodelTest.CategoricalSampler(5, otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentcategorical(s2, params)
		end

		test("random params") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			s1 = GodelTest.CategoricalSampler(5, params)
			s2 = GodelTest.CategoricalSampler(5, otherparams)	
			traces = map(1:100) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentcategorical(s2, params)
		end
		
		test("too few traces") do
			params = [0.1, 0.2, 0.4, 0.2, 0.1]
			s1 = GodelTest.CategoricalSampler(5, params)
			s2 = GodelTest.CategoricalSampler(5, otherparams)	
			traces = map(1:0) do i
				x, trace = GodelTest.sample(s1, (0,1))
				trace
			end
			@check isconsistentcategorical(s2, otherparams)
		end
		
	end
		
end

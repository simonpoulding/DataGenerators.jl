include("sampler_test_utils.jl")

describe("Normal Sampler") do

	describe("default construction") do

		s = DataGenerators.NormalSampler()

		test("numparams and paramranges") do
			@check DataGenerators.numparams(s) == 2
			prs = DataGenerators.paramranges(s)
			@check typeof(prs) <: Vector{(Float64,Float64)} 
			@check prs == [(-realmax(Float64), realmax(Float64)), (0.0, realmax(Float64))]
		end
	
		test("default params") do
			@check DataGenerators.getparams(s) == [0.0, 1.0]
			@check isconsistentnormal(s, DataGenerators.getparams(s))
		end
	
		@repeat test("default sampling") do
			x, trace = DataGenerators.sample(s, (0,1))
			@check typeof(x) <: Float64
			@mcheck_that_sometimes x < -1.0
			@mcheck_that_sometimes -1.0 <= x < 0.0
			@mcheck_that_sometimes 0.0 < x <= 1.0
			@mcheck_that_sometimes 1.0 < x
		end

	end
	
	describe("non-default construction") do

		s = DataGenerators.NormalSampler([-949.88, 123.4])
		
		test("constructor with params") do
			@check DataGenerators.getparams(s) == [-949.88, 123.4]
			@check isconsistentnormal(s, DataGenerators.getparams(s))
		end
		
	end
	
	describe("parameter setting") do
		
		s = DataGenerators.NormalSampler()
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
				@check isconsistentnormal(s, params)
				params[pidx] = prevfloat(pr[1])
				@check_throws DataGenerators.setparams(s, params)
				params[pidx] = pr[2] 
				DataGenerators.setparams(s, params)
				@check isconsistentnormal(s, params)
				params[pidx] = nextfloat(pr[2])
				@check_throws DataGenerators.setparams(s, params)
			end
		end

		test("setparams handles sigma=0") do
			params = [87.4, 0.0]
			DataGenerators.setparams(s, params)
			@check isconsistentnormal(s, params)
		end

		@repeat test("setparams with random parameters") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			DataGenerators.setparams(s, params)
			@check isconsistentnormal(s, params)
		end

		@repeat test("setparams with realistic random parameters") do
			params = [rand() * 2e6 - 1e6, rand() * 1e3]
			DataGenerators.setparams(s, params)
			@check isconsistentnormal(s, params)
		end

	end
	
	describe("estimate parameters") do
		
		s = DataGenerators.NormalSampler()
		prs = DataGenerators.paramranges(s)
		otherparams = [155.6, 13.7]
		
		test("non-zero sigma") do
			params = [-56.0, 18.9]
			s1 = DataGenerators.NormalSampler(params)
			s2 = DataGenerators.NormalSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentnormal(s2, params)
		end

		test("zero sigma") do
			params = [3.44, 0.0]
			s1 = DataGenerators.NormalSampler(params)
			s2 = DataGenerators.NormalSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			# @check isconsistentnormal(s2, params)
			# fails because of never exactly similar; instead we check parameters directly:
			s2params = DataGenerators.getparams(s2)
			@check abs(s2params[1]-params[1]) < 1e-10
			@check abs(s2params[2]-params[2]) < 1e-10
		end

		# random params can easily cause Inf sigma when fitted - not sure how to handle this sensibly
		# skip for the moment
		_test("random params") do
			params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
			# convulated expression involving middle to avoid overflow to Inf
			s1 = DataGenerators.NormalSampler(params)
			s2 = DataGenerators.NormalSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentnormal(s2, params)
		end

		test("realistic random params") do
			params = [rand() * 2e6 - 1e6, rand() * 1e3]
			s1 = DataGenerators.NormalSampler(params)
			s2 = DataGenerators.NormalSampler(otherparams)	
			traces = map(1:100) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			estimateparams(s2, traces)
			@check isconsistentnormal(s2, params)
		end
		
		test("too few traces") do
			params = [21.0, 0.7]
			s1 = DataGenerators.NormalSampler(params)
			s2 = DataGenerators.NormalSampler(otherparams)	
			traces = map(1:1) do i
				x, trace = DataGenerators.sample(s1, (0,1))
				trace
			end
			@check isconsistentnormal(s2, otherparams)
		end
		
	end
	
end

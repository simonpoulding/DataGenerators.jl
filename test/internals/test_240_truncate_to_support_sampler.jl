include("sampler_test_utils.jl")

describe("Truncate to Support Sampler") do

	describe("construction") do
		
		subsA = DataGenerators.NormalSampler([102.0, 45.81])
		s = DataGenerators.TruncateToSupportSampler(subsA)

		test("numparams and paramranges") do
			@check DataGenerators.numparams(s) == DataGenerators.numparams(subsA)
			@check DataGenerators.paramranges(s) == DataGenerators.paramranges(subsA)
		end
	
		test("default params") do
			@check DataGenerators.getparams(s) == DataGenerators.getparams(subsA)
		end

		test("set params") do
			DataGenerators.setparams(s, [-9.8, 0.002])
			@check DataGenerators.getparams(subsA) == [-9.8, 0.002]
			@check DataGenerators.getparams(s) == [-9.8, 0.002]
		end
			
	end
	
	describe("sampling from continuous with infinite support") do

		subsA = DataGenerators.NormalSampler([42.8, 98.77])
		s = DataGenerators.TruncateToSupportSampler(subsA)

		@repeat test("random support") do
			bounds = rand(2)*40.0-20.0
			l, u = minimum(bounds), maximum(bounds)
			x, trace = DataGenerators.sample(s, (l, u))
			@check typeof(x) <: Float64
			@check l <= x <= u
		end

		test("equal support") do
			bound = rand()*40.0-20.0
			for i in 1:100
				x, trace = DataGenerators.sample(s, (bound, bound))
				@check x == bound
			end
		end

		@repeat test("entire float range") do
			x, trace = DataGenerators.sample(s, (-realmax(Float64), realmax(Float64)))
			@check typeof(x) <: Float64
			@check isfinite(x)
			@mcheck_that_sometimes x < 0.0
			@mcheck_that_sometimes x > 0.0
		end
		
	end

	describe("sampling from continuous with finite support") do

		subsA = DataGenerators.UniformSampler([42.5, 79.67])
		s = DataGenerators.TruncateToSupportSampler(subsA)

		@repeat test("random support") do
			bounds = rand(2)*100.0
			l, u = minimum(bounds), maximum(bounds)
			x, trace = DataGenerators.sample(s, (l, u))
			@check typeof(x) <: Float64
			@check min(max(l,42.5),79.67) <= x <= max(min(u,79.67),42.5) # outer max/min because this is the fallback made by distributions.jl when the truncation and distribution support do not overlap
		end

		test("equal support") do
			bound = 51.8
			for i in 1:100
				x, trace = DataGenerators.sample(s, (float64(bound), float64(bound)))
				@check x == bound
			end
		end

		@repeat test("entire float range") do
			x, trace = DataGenerators.sample(s, (-realmax(Float64), realmax(Float64)))
			@check typeof(x) <: Float64
			@check isfinite(x)
			@check 42.5 <= x <= 79.67
		end
		
	end
	
	describe("estimate parameters") do
		
		test("estimates parameters of subsampler (when not too constrained)") do		

			subs1A = DataGenerators.NormalSampler()
			s1 = DataGenerators.TruncateToSupportSampler(subs1A)
			params = [94.2, 34.1]
			DataGenerators.setparams(s1, params)

			subs2A = DataGenerators.NormalSampler()
			s2 = DataGenerators.TruncateToSupportSampler(subs2A)
			otherparams = [-42.0, 50.1]
			DataGenerators.setparams(s2, otherparams)

			traces = map(1:100) do i
			 	# note: large support that rarely truncates, otherwise would not be able to estimate subsampler with same params
				x, trace = DataGenerators.sample(s1, (-500.0, 500.0))
				trace
			end

			estimateparams(s2, traces)
			
			@check isconsistentnormal(subs2A, params[1:2])

		end
		
	end
		
end

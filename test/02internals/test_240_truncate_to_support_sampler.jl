include("sampler_test_utils.jl")

describe("Truncate to Support Sampler") do

	describe("construction") do
		
		subsA = GodelTest.NormalSampler([102.0, 45.81])
		s = GodelTest.TruncateToSupportSampler(subsA)

		test("numparams and paramranges") do
			@check GodelTest.numparams(s) == GodelTest.numparams(subsA)
			@check GodelTest.paramranges(s) == GodelTest.paramranges(subsA)
		end
	
		test("default params") do
			@check GodelTest.getparams(s) == GodelTest.getparams(subsA)
		end

		test("set params") do
			GodelTest.setparams(s, [-9.8, 0.002])
			@check GodelTest.getparams(subsA) == [-9.8, 0.002]
			@check GodelTest.getparams(s) == [-9.8, 0.002]
		end
			
	end
	
	describe("sampling from continuous with infinite support") do

		subsA = GodelTest.NormalSampler([42.8, 98.77])
		s = GodelTest.TruncateToSupportSampler(subsA)

		@repeat test("random support") do
			bounds = rand(2)*40.0-20.0
			l, u = minimum(bounds), maximum(bounds)
			x, trace = GodelTest.sample(s, (l, u))
			@check typeof(x) <: Float64
			@check l <= x <= u
		end

		test("equal support") do
			bound = rand()*40.0-20.0
			for i in 1:100
				x, trace = GodelTest.sample(s, (bound, bound))
				@check x == bound
			end
		end

		@repeat test("entire float range") do
			x, trace = GodelTest.sample(s, (-realmax(Float64), realmax(Float64)))
			@check typeof(x) <: Float64
			@check isfinite(x)
			@mcheck_that_sometimes x < 0.0
			@mcheck_that_sometimes x > 0.0
		end
		
	end

	describe("sampling from continuous with finite support") do

		subsA = GodelTest.UniformSampler([42.5, 79.67])
		s = GodelTest.TruncateToSupportSampler(subsA)

		@repeat test("random support") do
			bounds = rand(2)*100.0
			l, u = minimum(bounds), maximum(bounds)
			x, trace = GodelTest.sample(s, (l, u))
			@check typeof(x) <: Float64
			@check min(max(l,42.5),79.67) <= x <= max(min(u,79.67),42.5) # outer max/min because this is the fallback made by distributions.jl when the truncation and distribution support do not overlap
		end

		test("equal support") do
			bound = 51.8
			for i in 1:100
				x, trace = GodelTest.sample(s, (float64(bound), float64(bound)))
				@check x == bound
			end
		end

		@repeat test("entire float range") do
			x, trace = GodelTest.sample(s, (-realmax(Float64), realmax(Float64)))
			@check typeof(x) <: Float64
			@check isfinite(x)
			@check 42.5 <= x <= 79.67
		end
		
	end
	
	describe("estimate parameters") do
		
		test("estimates parameters of subsampler (when not too constrained)") do		

			subs1A = GodelTest.NormalSampler()
			s1 = GodelTest.TruncateToSupportSampler(subs1A)
			params = [94.2, 34.1]
			GodelTest.setparams(s1, params)

			subs2A = GodelTest.NormalSampler()
			s2 = GodelTest.TruncateToSupportSampler(subs2A)
			otherparams = [-42.0, 50.1]
			GodelTest.setparams(s2, otherparams)

			traces = map(1:100) do i
			 	# note: large support that rarely truncates, otherwise would not be able to estimate subsampler with same params
				x, trace = GodelTest.sample(s1, (-500.0, 500.0))
				trace
			end

			estimateparams(s2, traces)
			
			@check isconsistentnormal(subs2A, params[1:2])

		end
		
	end
		
end

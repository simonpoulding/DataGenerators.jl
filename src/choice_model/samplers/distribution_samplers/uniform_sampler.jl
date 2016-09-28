#
# Uniform Sampler
#
# parameters:
# 	(1) a (lower bound)
#	(2) b (upper bound)
#

type UniformSampler <: ContinuousDistributionSampler
	paramranges::Vector{Tuple{Float64,Float64}}
	distribution::Union{Uniform,Float64}
	# to handle case where a==b (which raises error in Uniform), we
	# indicate this case by setting distribution to a fixed value
	function UniformSampler(params=Float64[])
		s = new( [(-realmax(Float64), realmax(Float64)), (-realmax(Float64), realmax(Float64))] )
		# rather than defaulting to entire float range, we use a 'pragmatic' (and arbitrary) range of [-1.0, 1.0]
		setparams(s, isempty(params) ? [-1.0, 1.0] : params)
		s
	end
end

function setparams(s::UniformSampler, params)
	checkparamranges(s, params)
	# swap parameters if necessary (as a silent repair during search)
	if params[1] <= params[2]
		a, b = params[[1,2]]
	else
		a, b = params[[2,1]]
	end
	# note that Distributions.Uniform samples from closed interval [a,b], but currently raises an error when a==b, temporary workaround:
	if a==b
		s.distribution = b
		# see note in type definition: this is workaround for error raised in Uniform constructor when a==b
	else
		# adjust a,b to be at most realmax(Float64) apart, otherwise Uniform will always return Inf
		m = robustmidpoint(a,b) # util function that avoids overflow to Inf
		if (m-a) > realmax(Float64)/2
			a = m - realmax(Float64)/2
			b = m + realmax(Float64)/2
			# warn("interval of Uniform sampler adjusted to [$a,$b]")
		end
		s.distribution = Uniform(a, b)
	end
end

getparams(s::UniformSampler) = typeof(s.distribution) <: Uniform ? [s.distribution.a, s.distribution.b] : [s.distribution, s.distribution]

function sample(s::UniformSampler, support)
 x = typeof(s.distribution) <: Uniform ? rand(s.distribution) : s.distribution
 # we return both the sampled value, and a dict as trace information
 x, Dict{Symbol, Any}(:rnd=>x)
end

function estimateparams(s::UniformSampler, traces)
	samples = extractsamplesfromtraces(s, traces)
	minnumsamples = 1
	if length(samples) >= minnumsamples
		if all(samples.==samples[1])
			# distribution gives error if all samples are the same
			s.distribution = samples[1]
		else
			s.distribution = fit(Uniform, samples)
		end
	end
end

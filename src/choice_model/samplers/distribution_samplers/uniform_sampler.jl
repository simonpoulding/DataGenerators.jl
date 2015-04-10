#
# Uniform Sampler
#
# parameters:
# 	(1) a (lower bound)
#	(2) b (upper bound)
#

type UniformSampler <: ContinuousDistributionSampler
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::Uniform
	function UniformSampler(params=Float64[])
		floatbounds = (typemin(Float64), typemax(Float64))
		s = new([floatbounds, floatbounds])
		# rather than defaulting to entire int range, we use a 'pragmatic' (and arbitrary) range of [-1.0, 1.0]
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
	# Distributions.Uniform returns samples of NaN if lower bound is -Inf,
	# and (+)Inf if length of domain is more than (approx?) realmax(Float64) ~= 1.79e308
	# therefore limit lower and upper bounds to -/+ realmax(Float64) / 2
	bound = realmax(Float64)/2
	if a < -bound
		a = -bound
		warn("lower bound adjusted to $(adjustedparams[1]) in UniformSampler")
	end
	if b > bound
		b = bound
		warn("upper bound adjusted to $(adjustedparams[2]) in UniformSampler")
	end
	s.distribution = Uniform(a, b)
end

getparams(s::UniformSampler) = [s.distribution.a, s.distribution.b]

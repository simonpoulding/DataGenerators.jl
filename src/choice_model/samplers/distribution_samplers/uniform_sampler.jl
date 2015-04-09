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
	function UniformSampler(params::Vector{Float64}=Float64[])
		lbound, ubound = typemin(Float64), typemax(Float64)
		s = new([(lbound,ubound), (lbound,ubound)])
		setparams(s, isempty(params) ? [lbound, ubound] : params)
		s
	end
end

function setparams(s::UniformSampler, params::Vector{Float64})
	checkparamranges(s, params)
	# swap parameters if necessary (as a silent repair during search)
	if params[1] <= params[2]
		orderedparams = params[[1,2]]
	else
		orderedparams = params[[2,1]]
	end
	# Distributions.Uniform returns samples of NaN if lower bound is -Inf,
	# and (+)Inf if length of domain is more than (approx?) realmax(Float64) ~= 1.79e308
	# therefore limit lower and upper bounds to -/+ realmax(Float64) / 2
	bound = realmax(Float64)/2
	if orderedparams[1] < -bound
		orderedparams[1] = -bound
		warn("lower bound adjusted to $(orderedparams[1]) in UniformSampler")
	end
	if orderedparams[2] > bound
		orderedparams[2] = bound
		warn("upper bound adjusted to $(orderedparams[2]) in UniformSampler")
	end
	s.params = orderedparams
	s.distribution = Uniform(orderedparams[1], orderedparams[2])
end

# TODO should sample actually sample Inf?


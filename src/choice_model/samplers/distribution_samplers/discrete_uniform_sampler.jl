#
# Discrete Uniform Sampler
#
# parameters:
# 	(1) a (lower bound)
#	(2) b (upper bound)
#

type DiscreteUniformSampler <: DiscreteDistributionSampler
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::DiscreteUniform
	function DiscreteUniformSampler(params::Vector{Float64}=Float64[])
		lbound, ubound = float64(typemin(Int)), float64(typemax(Int))
		s = new([(lbound,ubound), (lbound,ubound)])
		setparams(s, isempty(params) ? [lbound, ubound] : params)
		s
	end
end

function setparams(s::DiscreteUniformSampler, params::Vector{Float64})
	checkparamranges(s, params)
	# swap parameters if necessary (as a silent repair during search)
	if params[1] <= params[2]
		orderedparams = params[[1,2]]
	else
		orderedparams = params[[2,1]]
	end
	# we convert temporarily to int128 to avoid InexactErrors that can arise because
	# for example int(float64(typemax(Int))) is above typemax(Int) owing to rounding errors
	# (since it is a rounding error, we do this silently)
	orderedparams = int128(round(orderedparams))
	if orderedparams[1] < typemin(Int)
		orderedparams[1] = typemin(Int)
	end
	if orderedparams[2] > typemax(Int)
		orderedparams[2] = typemax(Int)
	end
	# now can convert to default Int on the platform
	orderedparams = int(orderedparams)
	if orderedparams[1] == typemin(Int) && orderedparams[2] == typemax(Int)
		# if the entire Int domain,  Distributions.DiscreteUniform raises an error, so
		# here choose to adjust lower part of range to avoid the error
		orderedparams[1] = typemin(Int)+1
		warn("lower bound adjusted to $(orderedparams[1]) in DiscreteUniformSampler")
	end
	s.params = orderedparams
	s.distribution = DiscreteUniform(orderedparams[1], orderedparams[2])
end

#
# Discrete Uniform Sampler
#
# parameters:
# 	(1) a (lower bound)
#	(2) b (upper bound)
#

type DiscreteUniformSampler <: DiscreteDistributionSampler
	paramranges::Vector{(Float64,Float64)}
	distribution::DiscreteUniform
	function DiscreteUniformSampler(params=Float64[])
		intbounds = (float64(typemin(Int)), float64(typemax(Int)))
		s = new([intbounds, intbounds])
		# rather than defaulting to entire int range, we use a 'pragmatic' (and arbitrary) default of the 16-bit range
		setparams(s, isempty(params) ? [float64(typemin(Int16)), float64(typemax(Int16))] : params)
		s
	end
end

function setparams(s::DiscreteUniformSampler, params)
	checkparamranges(s, params)
	# swap parameters if necessary (as a silent repair during search)
	if params[1] <= params[2]
		a, b = params[[1,2]]
	else
		a, b = params[[2,1]]
	end
	# we convert temporarily to int128 to avoid InexactErrors that can arise because
	# for example int(float64(typemax(Int))) is above typemax(Int) owing to rounding errors
	# (since it is a rounding error, we do this silently)
	a, b = int128(round(a)), int128(round(b))
	if a < typemin(Int)
		a = typemin(Int)
	end
	if b > typemax(Int)
		b = typemax(Int)
	end
	# now can convert to default Int on the platform
	a, b = int(a), int(b)
	if a == typemin(Int) && b == typemax(Int)
		# if the entire Int domain,  Distributions.DiscreteUniform raises an error, so
		# here choose to adjust lower part of range to avoid the error
		a = typemin(Int)+1
		warn("interval of DiscreteUniform sampler adjusted to [$a,$b]")
	end
	s.distribution = DiscreteUniform(a, b)
end

getparams(s::DiscreteUniformSampler) = [float64(s.distribution.a), float64(s.distribution.b)]
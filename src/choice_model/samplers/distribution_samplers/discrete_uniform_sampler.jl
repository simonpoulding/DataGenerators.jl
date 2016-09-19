#
# Discrete Uniform Sampler
#
# parameters:
# 	(1) a (lower bound)
#	(2) b (upper bound)
#

type DiscreteUniformSampler <: DiscreteDistributionSampler
	paramranges::Vector{Tuple{Float64,Float64}}
	distribution::DiscreteUniform
	function DiscreteUniformSampler(params=Float64[])
		intbounds = (Float64(typemin(Int)), Float64(typemax(UInt)))
		s = new([intbounds, intbounds])
		# rather than defaulting to entire int range, we use a 'pragmatic' (and arbitrary) default of the 16-bit range
		setparams(s, isempty(params) ? [Float64(typemin(Int16)), Float64(typemax(Int16))] : params)
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
	# # we convert temporarily to Int128 to avoid InexactErrors that can arise because
	# # for example Int(Float64(typemax(Int))) is above typemax(Int) owing to rounding errors
	# # (since it is a rounding error, we do this silently)
	# a, b = round(Int128,a), round(Int128,b)
	# if a < typemin(Int)
	# 	a = typemin(Int)
	# end
	# if b > typemax(Int)
	# 	b = typemax(Int)
	# end
	# # now can convert to default Int on the platform
	# a, b = Int(a), Int(b)
	# if a == typemin(Int) && b == typemax(Int)
	# 	# if the entire Int domain,  Distributions.DiscreteUniform raises an error, so
	# 	# here choose to adjust lower part of range to avoid the error
	# 	a = typemin(Int)+1
	# 	warn("interval of DiscreteUniform sampler adjusted to [$a,$b]")
	# end
	#
	# in latest version of Distributions, InexactError appears to be raised even when 
	# range is quite far from type bounds, so replace above manipulation with this
	# more aggressive one
	desiredrange = convert(Float64, b) - convert(Float64, a)
	allowedrange = (convert(Float64, typemax(Int)) - convert(Float64, typemin(Int))) / 2.1	 # 2.1 found empirically
	if desiredrange > allowedrange
		factor = allowedrange / desiredrange
		a, b = convert(Int, a * factor), convert(Int, b * factor)
	 	warn("interval of DiscreteUniform sampler adjusted to [$a,$b]")
	end
	s.distribution = DiscreteUniform(a, b)
end

getparams(s::DiscreteUniformSampler) = [Float64(s.distribution.a), Float64(s.distribution.b)]
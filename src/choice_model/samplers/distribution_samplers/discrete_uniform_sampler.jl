#
# Discrete Uniform Sampler
#
# parameters:
# 	(1) a (lower bound)
#	(2) b (upper bound)
#
const ONE_EIGTH_INT_RANGE = (typemax(Int)>>3) - (typemin(Int)>>3) # this formulation avoids overflow

type DiscreteUniformSampler <: DiscreteDistributionSampler
	paramranges::Vector{Tuple{Float64,Float64}}
	params::Vector{Float64}
	distribution::Distribution
	function DiscreteUniformSampler(params=Float64[])
		intbounds = (Float64(typemin(Int)), Float64(typemax(Int)))
		s = new([intbounds, intbounds])
		setparams!(s, isempty(params) ? [Float64(typemin(Int)), Float64(typemax(Int))] : params)
		s
	end
end

function setparams!(s::DiscreteUniformSampler, params)
	checkparamranges(s, params)
	# note the paramranges check will trap an attempt to sample from the entire UInt range: this cannot be supported
	# since Distributions.Uniform currently only supports Int range (and then only with the workaround below using a Mixture Model)
	# swap parameters if necessary (as a silent repair during search)
	if params[1] <= params[2]
		a, b = params[[1,2]]
	else
		a, b = params[[2,1]]
	end
	# convert to Int, but with a check to avoid InexactError when at bounds since params will be Float64 and imprecision means
	# that the values can be outside range	
	a = a < typemin(Int) ? typemin(Int) : round(Int, a, RoundUp) # round up so that value sampled remain in unrounded range
	b = b > typemax(Int) ? typemax(Int) : round(Int, b, RoundDown) # round down so that value sampled remain in unrounded range
	# if range is too large (more than one quarter of entire Int range), then must use Mixture
	# distribution instead to avoid InexactErrors when sampling from DiscreteUniform
	halfrange = (b>>1) - (a>>1) # >> 1 formulation avoids overflow by calculating half range
	if  halfrange < ONE_EIGTH_INT_RANGE 
		s.distribution = DiscreteUniform(a, b)
	else
		# in the worst case (the entire Int range), we must split into four ranges for the
		# mixture model if we are to avoid errors, so let's always do this
		quarterrange = halfrange >> 1  # one quarter desired range
		q1 = a + quarterrange
		q2 = q1 + quarterrange
		q3 = q2 + quarterrange
		prior = [Float64(q1)-Float64(a)+1, Float64(q2)-Float64(q1), Float64(q3)-Float64(q2), Float64(b)-Float64(q3)]
		s.distribution = MixtureModel(
			[DiscreteUniform(a,q1), DiscreteUniform(q1+1,q2), DiscreteUniform(q2+1,q3),  DiscreteUniform(q3+1,b)], prior ./ sum(prior))
	end
	s.params = [Float64(a), Float64(b)]
end

getparams(s::DiscreteUniformSampler) = s.params

estimateparams!(s::DiscreteUniformSampler, traces) = estimateparams!(s, traces, 2)

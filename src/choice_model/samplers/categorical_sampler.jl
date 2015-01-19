#
# Categorical Sampler
# - uses a Categorical distribution that has a support over the range 1:numcategories
#

type CategoricalSampler <: Sampler
	nparams					# number of parameters is the domain length (number of values specified in the range)
	params::Vector{Float64}
	dist::Categorical
	distminimum				# minimum value of the underlying distribution's support
	fallbackbound			# bound at which any we fall back to uniform to avoid excessive resampling
	function CategoricalSampler(numcategories, params = Float64[])
		s = new(numcategories)
		# TODO strictly, could parameterise using number of parameters that is one less than the domain size
		if length(params) == 0
			params = fill(1.0/s.nparams, s.nparams)
		end
		setparams(s, params)
		s
	end
end

function setparams(s::CategoricalSampler, params::Vector)
	if length(params) != numparams(s)
		error("expected $(numparams(s)) sampler parameter(s), but got $(length(params))")
	end
	totalweight = sum(params)
	if totalweight == 0.0
		params = fill(1.0/s.nparams, s.nparams)
	elseif totalweight != 1.0
		map!((weight)->(weight/totalweight), params)
	end
	# TODO for the moment, we assume that sum of params is close enough (even with rounding errors) to 1.0 to satisfy the Categorical constructor
	# @assert sum(params) == 1.0
	s.params = params
	s.dist = Categorical(s.params)
	s.distminimum = minimum(s.dist)
	# fallback bound is set to the lower quartile range of the distribution
	s.fallbackbound = quantile(s.dist,0.25) - s.distminimum
end

paramranges(s::CategoricalSampler) = fill((0.0,1.0), s.nparams)

getparams(s::CategoricalSampler) = s.params

function godelnumber(s::CategoricalSampler, cc::ChoiceContext)
	if (cc.upperbound - cc.lowerbound) < s.fallbackbound
		# if range is smaller than the fallback range, then multiple resamplings are likely: fall back to a uniform distribution
		# info("categorical falling back to discrete uniform")
		lowerbound, upperbound = adjust_bounds_for_discrete_uniform(cc)
		rand(DiscreteUniform(lowerbound, upperbound))
	else
		cc.lowerbound - s.distminimum + rand(s.dist)	
	end
end

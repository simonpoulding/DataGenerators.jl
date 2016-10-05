#
# Categorical Sampler
#
# parameters:
# (1)-(n)  0 <= w_i <= 1
#

type CategoricalSampler <: DiscreteDistributionSampler
	numcategories::Int
	paramranges::Vector{Tuple{Float64,Float64}}
	distribution::Categorical
	function CategoricalSampler(numcategories::Int, params=Float64[])
		numcategories >= 1 || error("number of categories must be at least one")
		s = new(numcategories, fill((0.0,1.0), numcategories))
		# Note: could parameterise using number of parameters that is one less than the domain size
		# but there is not an obvious way to do this in a symmetrical way so as not bias any optimisation
		# of the parameters
		setparams(s, isempty(params) ? fill(1.0, numcategories) : params)
		s
	end
end

function setparams(s::CategoricalSampler, params)
	checkparamranges(s, params)
	totalweight = sum(params)
	if totalweight == 0.0
		weights = fill(1.0/s.numcategories, s.numcategories)
	else
		weights = params ./ totalweight
	end
	# TODO we assume that sum of params is close enough (even with rounding errors) to 1.0 to satisfy the Categorical constructor
	# so we do not need handle the rounding errors
	s.distribution = Categorical(weights)
end

getparams(s::CategoricalSampler) = copy(s.distribution.p)

function estimateparams(s::CategoricalSampler, traces)
	samples = extractsamplesfromtraces(s, traces)
	if length(samples) >= 1
		s.distribution = fit(getdistributiontype(s), samples)
		# if there is a sequence of values at the end of the categories with zero probabilities,
		# then the fit will reduce the number of categories which will cause get parameters to return too
		# few values - we fix this here by padding with zeros
		if length(s.distribution.p) < s.numcategories
			s.distribution = Categorical([copy(s.distribution.p); fill(0.0, s.numcategories - length(s.distribution.p))])
		end
	end
end


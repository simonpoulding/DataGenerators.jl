using Distributions

export SamplerChoiceModel


#
# SamplerChoiceModel
#

# A sampler is either a probability distribution, or a sampler that modifies other samplers.
abstract Sampler

#
# The expected interface of a sampler is:
#
#	numparams(s::Sampler)
#		- the number parameters (including those of any samplers this sampler modifies)
# setparams(s::Sampler, params::Vector{Float64})
#		- updates the parameters of the sampler (if the sampler modifies another, this sets the parameter of both)
#	paramranges(s::Sampler)
#		- returns an array specifying the valid ranges for each parameter of the sampler (if the sampler modifies others, 
#         returns the parameter ranges of the modified sampler as well)
# getparams(s::Sampler)
#		- returns the current parameters (currently used only to default parameters of a modifying sampler)
#	godelnumber(s::Sampler, cc::ChoiceContext)
#		- sample a Gödel number from the sampler

#	Note also that for consistency, samplers allow parameters to be specified in their constructor, but if
# the parameter array is empty, sensible defaults are set instead.  However, this is not required.

# It is assumed that the number of parameters remains constant after construction, and so, for efficiency, 
# samplers can store the number of parameters as a field in the type and use the following method to return the value:
numparams(s::Sampler) = s.nparams



#
# SamplerChoiceModel
#

# The sampler choice model is a set of samplers, one assigned to each choice point (indexed by choice point id)
type SamplerChoiceModel <: ChoiceModel
	samplers::Dict{Uint, Sampler}
end

#
# Default mapping of sampler types to choice point info.
#
# choose_rule => Categorical
#		justification: expected be a small range, is guaranteed to be closed, and no meaning is attached to order
#		varying bounds: not possible
#		infinite bounds: not possible
#
# choose_reps => Geometric
#		justification: often builds recursive structures, so smaller number of repetitions should be more likely
#		varying bounds: lower handled by offset; upper by rejection sampling
#		infinite bounds: infinite lower not possible; infinite upper is compatible with Geometric, but
#     upper is actually limited to typemax(Int) by the implementaton since choose_reps returns an integer
#
# choose_number
#			Bool => Bernoulli
#				justification: two mutually exclusive outcomes, so natural choice
#				varying bounds: not possible
#				infinite bounds: not possible
#			Integer => DiscreteUniform
#				justification: (for the moment) simplicity
#				varying bounds: range of distribution is adapted
#				infinite bounds: not possible: typemin(Type) and typemax(Type) are the largest possible values
#												 (note: some practical limitations on datatypes that are default Int or wider - see comment in DiscreteUniformSampler)
#			FloatingPoint => Uniform
#				justification: (for the moment) simplicity
#				varying bounds: range of distribution is adapted
#				infinite bounds: (finitized to arbitarily large values for practical reasons - see comment in UniformSampler)
#
function SamplerChoiceModel(g::Generator, subgencms=[])
	samplers = (Uint=>Sampler)[]
	for (cpid, info) in choicepointinfo(g) # gets info from sub-generators also
		cptype = info[:type]
		if cptype == RULE_CP
			sampler = CategoricalSampler(info[:max])
		elseif cptype == SEQUENCE_CP
			sampler = GeometricSampler()
		elseif cptype == VALUE_CP
			datatype = info[:datatype]
			if datatype <: Bool
				sampler = BernoulliSampler()
			elseif datatype <: Integer # order of if clauses matters here since Bool <: Integer
				sampler = DiscreteUniformSampler()
			else # floating point, but may also be a rational type
				sampler = UniformSampler()
			end
		else
			error("unrecognised choice point type when creating sampler choice model")
		end
		samplers[cpid] = sampler
	end
	for subgencm in subgencms
		merge!(samplers, subgencm.samplers)
	end
	SamplerChoiceModel(samplers)
end



#
# GodelTest interface
#

# retrieve the sampler for this choice point and then ask it to return a godel number
# resample if necessary - usually because upperbound cannot be enforced directly by sampler
function godelnumber(cm::SamplerChoiceModel, cc::ChoiceContext)
	
	# avoid case when lower and upper bound are equal: the Uniform and DiscreteUniform samplers require the bounds to differ, and in any case there is no
	# need to sample a random value
	if cc.lowerbound == cc.upperbound
		return cc.lowerbound
	end
	
	# sample from sampler assigned to the choice point
	sampler = cm.samplers[cc.cpid]
	samplecount = 0
	while samplecount <= 10
		gn = godelnumber(sampler, cc)
		if cc.lowerbound <= gn <= cc.upperbound
			return gn
		end
		samplecount += 1
	end
	
	# if too many resamplings, fall back to a uniform distribution
	# note: Geometric and Categorical samplers already *silently* fall back to a uniform distribution if it appears *in advance* that multiple resamplings will be necessary
	# the code here is an additional catch-all to ensure that a conformant godel number will be always be returned - it should only rarely be needed
	if cc.datatype <: Integer # includes Bool
		warn("sampled $(samplecount) times without success for a value between $(cc.lowerbound) and $(cc.upperbound): falling back to a discrete uniform distribution")
		lowerbound, upperbound = adjust_bounds_for_discrete_uniform(cc)
		gn = rand(DiscreteUniform(lowerbound, upperbound))
	elseif cc.datatype <: FloatingPoint
		warn("sampled $(samplecount) times without success for a value between $(cc.lowerbound) and $(cc.upperbound): falling back to a uniform distribution")
		lowerbound, upperbound = adjust_bounds_for_uniform(cc)
		gn = rand(Uniform(lowerbound, upperbound))
	else
		# shouldn't occur
		error("sampled $(samplecount) times without success for a value between $(cc.lowerbound) and $(cc.upperbound), but have no alternative")
	end
	gn
end



#
# Methods applied to the model as a whole (in order to apply search)
#

# Note: model_paramranges, set_model_params and get_model_params the following assumption: the iteration order of values from
# the samplers dictionary remains consistent (it need not be the order in which entries are initially specified)

# get total number of sampler parameters
numparams(cm::SamplerChoiceModel) = sum(map((sampler)->numparams(sampler), values(cm.samplers)))

# get parameter ranges for all samplers
function paramranges(cm::SamplerChoiceModel)
	ranges = (Float64,Float64)[]
	for sampler in values(cm.samplers)
		ranges = [ranges, paramranges(sampler)]
	end
	ranges
end

# set parameters of all samplers
function setparams(cm::SamplerChoiceModel, params)
	params = convert(Vector{Float64},params)
	if length(params) != numparams(cm)
		error("expected $(numparams(cm)) model parameter(s), but got $(length(params))")
	end
	idx = 1
	for sampler in values(cm.samplers)
		nparams = numparams(sampler)
		# TODO replace this with a check on getnummodelparams
		@assert (idx+nparams-1)<=length(params)
		setparams(sampler, params[idx:(idx+nparams-1)])
		# note: it is important here that sampler works on a copy of the parameters (which is ensured by [range] syntax)
		# as the sampler may adjust its parameters
		idx += nparams
	end
end

# get parameters of all samplers
function getparams(cm::SamplerChoiceModel)
	params = (Float64)[]
	for sampler in values(cm.samplers)
		params = [params, getparams(sampler)]
	end
	params
end



#
# Geometric Sampler
# - uses a Geometric distribution that (by default) has a support of [0,+Inf)
# Note that this interprets the one parameter [p] in the same way as the underlying Distributions.Geometric type, i.e.
# values close to 1.0 are unlikely to sample numbers above 0, while values close to 0.0 have samples with a large mean.
# This is the opposite interpretation to the Ruby implementation (and to Boltzmann Samplers), and so is NOT the most
# convenient one for modification with the Decay Sampler
#

type GeometricSampler <: Sampler
	nparams
	params::Vector{Float64}
	dist::Geometric
	distminimum				# minimum value of the underlying distribution's support
	fallbackbound			# bound at which any we fall back to uniform to avoid excessive resampling
	function GeometricSampler(params = Float64[])
		s = new(1)
		if length(params) == 0
			params = [0.5]
		end
		setparams(s, params)
		s
	end
end

function setparams(s::GeometricSampler, params::Vector)
	if length(params) != numparams(s)
		error("expected $(numparams(s)) sampler parameters, but got $(length(params))")
	end
	# the parameter for Geometric must be in the open interval (0,1), so adjust if necessary:
	params = convert(Vector{Float64},params)
	params[1] = min(1.0-1e-5, max(1e-5, params[1]))
	# note: using eps for lower bound is insufficient to prevent InexactError when sampling
	s.params = params
	s.dist = Geometric(s.params[1])
	s.distminimum = minimum(s.dist)
	# fallback bound is set to the lower quartile range of the distribution
	s.fallbackbound = quantile(s.dist,0.25) - s.distminimum
end

paramranges(s::GeometricSampler) = [(0.0, 1.0)]

getparams(s::GeometricSampler) = s.params

function godelnumber(s::GeometricSampler, cc::ChoiceContext)
	if (cc.upperbound - cc.lowerbound) < s.fallbackbound
		# if range is smaller than the fallback range, then multiple resamplings are likely: fall back to a uniform distribution
		# info("geometric falling back to discrete uniform")
		lowerbound, upperbound = adjust_bounds_for_discrete_uniform(cc)
		rand(DiscreteUniform(lowerbound, upperbound))
	else
		cc.lowerbound - s.distminimum + rand(s.dist)
	end
end



#
# Discrete Uniform Sampler
# - uses a Discrete Uniform distribution that has a support of [lowerbound, upperbound] as specified by the choicepoint
#

type DiscreteUniformSampler <: Sampler
	nparams
	dist::DiscreteUniform
	function DiscreteUniformSampler()
		new(0, DiscreteUniform())
	end
end

function setparams(s::DiscreteUniformSampler, params::Vector)
	if length(params) != numparams(s)
		error("expected $(numparams(s)) sampler parameter(s), but got $(length(params))")
	end
end

paramranges(s::DiscreteUniformSampler) = (Float64,Float64)[]

getparams(s::DiscreteUniformSampler) = (Float64)[]

function godelnumber(s::DiscreteUniformSampler, cc::ChoiceContext)
	lowerbound, upperbound = adjust_bounds_for_discrete_uniform(cc)
	if (lowerbound != minimum(s.dist)) || (upperbound != maximum(s.dist))
		s.dist = DiscreteUniform(lowerbound, upperbound)
	end
	rand(s.dist)
end

# range larger than typemin(Int)+1 to typemax(Int) causes error in rand(DiscreteUniform()), so we adjust
function adjust_bounds_for_discrete_uniform(cc::ChoiceContext)
	lowerbound = (cc.lowerbound >= (typemin(Int) + 1)) ? cc.lowerbound : (typemin(Int) + 1) 
	upperbound = (cc.upperbound <= typemax(Int)) ? cc.upperbound : typemax(Int)
	lowerbound, upperbound
end



#
# Uniform Sampler
# - uses a Uniform distribution that has a support of [lowerbound, upperbound] as specified by the choicepoint
#

type UniformSampler <: Sampler
	nparams
	dist::Uniform
	function UniformSampler()
		new(0, Uniform())
	end
end

function setparams(s::UniformSampler, params::Vector)
	if length(params) != numparams(s)
		error("expected $(numparams(s)) sampler parameter(s), but got $(length(params))")
	end
end

paramranges(s::UniformSampler) = (Float64,Float64)[]

getparams(s::UniformSampler) = (Float64)[]

function godelnumber(s::UniformSampler, cc::ChoiceContext)
	lowerbound, upperbound = adjust_bounds_for_uniform(cc)
	if (lowerbound != minimum(s.dist)) || (upperbound != maximum(s.dist))
		s.dist = Uniform(lowerbound, upperbound)
	end
	rand(s.dist)
end

# rand(Uniform()) returns NaN for infinite ranges, so we adjust to large finite value
function adjust_bounds_for_uniform(cc::ChoiceContext)
	# finitise infinities to maxintfloat()/10 (approx 9e14 for Float64)
	# using a range that has a size that is less than maxintfloat ensures that the range is small enough that some of the Godel numbers
	# are, after conversion back to the datatype, have a non-zero floating point part
	lowerbound = isfinite(cc.lowerbound) ? cc.lowerbound : sign(cc.lowerbound) * maxintfloat(cc.datatype) / 10
	upperbound = isfinite(cc.upperbound) ? cc.upperbound : sign(cc.upperbound) * maxintfloat(cc.datatype) / 10
	lowerbound, upperbound
end



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



#
# Bernoulli Sampler
# - uses a Bernoulli distribution
#

type BernoulliSampler <: Sampler
	nparams
	params::Vector{Float64}
	dist::Bernoulli
	distminimum				# minimum value of the underlying distribution's support
	function BernoulliSampler(params = Float64[])
		s = new(1)
		if length(params) == 0
			params = [0.5]
		end
		setparams(s, params)
		s
	end
end

function setparams(s::BernoulliSampler, params::Vector)
	if length(params) != numparams(s)
		error("expected $(numparams(s)) sampler parameters, but got $(length(params))")
	end
	# the parameter for Bernoulli must be in the closed interval [0,1], so adjust if necessary:
	params[1] = min(1.0, max(0.0, params[1]))
	s.params = params
	s.dist = Bernoulli(s.params[1])
	s.distminimum = minimum(s.dist)
end

paramranges(s::BernoulliSampler) = [(0.0, 1.0)]

getparams(s::BernoulliSampler) = s.params

godelnumber(s::BernoulliSampler,  cc::ChoiceContext) = cc.lowerbound - s.distminimum + rand(s.dist)



#
# Decay Uniform Sampler
# - modifies another sampler according to the recursion depth of the current generator
# TODO: is the recursion depth of the current generator the correct definition?  Does a choice point have a meaningful 
# recursion depth that is independent of its generator?
# It takes a number of parameters (q_1, q_2, ..., q_n) where the n parameters of the modified sampler (p_1, p_2, ..., p_n)
# If the recursion depth is d >= 0, the p_i is modified to be p_i * (q_i ^ d)
#
# To improve performance, as each recursion depth is encountered, the corresponding child sampler is cached in order
# to avoid recreating samplers and their corresponding Distribution objects.
# This cache does NOT need to be reset when the choice model is reset since caching does not affect the functionality.
#
# type DecaySampler <: Sampler
# 	childsampler::Sampler
# 	numchildparams
# 	nparams
# 	cachedchildsamplers::Dict	# caches a child sampler for each recursion depth encountered
# 	params::Vector{Float64} 	# stores both the decay parameters (first half) and the parameters of the child sampler (second half)
# 	function DecaySampler(childsampler, params = Float64[])
# 		s = new(childsampler, numparams(childsampler), 2numparams(childsampler), (Int=>Sampler)[])
# 		if length(params) == 0
# 			params = [fill(1.0, s.numchildparams), getparams(s.childsampler)]
# 		end
# 		setparams(s, params)
# 		s
# 	end
# end
#
# function setparams(s::DecaySampler, params::Vector{Float64})
#
# 	if length(params) != numparams(s)
# 		error("Expected $(numparams(s)) sampler parameter(s), but got $(length(params))")
# 	end
#
# 	# split into parameters controlling decay, and the parameters of the child sampler
# 	decayparams = params[1:s.numchildparams]
# 	childparams = params[(s.numchildparams+1):end]
#
# 	# set params of the child sampler: this enables a check of parameters, and enables the adjusted parameters to be queried
# 	# (note that these are the parameters of the child sampler for recursion depth 0 only)
# 	setparams(s.childsampler, childparams)
#
# 	# adjust decay parameters
# 	map!((decayparam)->min(1.0, max(0.0, decayparam)), decayparams)
#
# 	# set params to be combination of adjusted decay params and the adjusted level 0 child sampler params
# 	s.params = [decayparams, getparams(s.childsampler)]
#
# 	# clear cached samplers and add new child sampler as the entry for depth 0
# 	empty!(s.cachedchildsamplers)
# 	s.cachedchildsamplers[0] = s.childsampler
#
#
# end
#
# paramranges(s::DecaySampler) = fill((0.0,1.0), s.nparams)
# # TODO should values outside [0.0,1.0] be allowed?
#
# getparams(s::DecaySampler) = s.params
#
# function godelnumber(s::DecaySampler, cc::ChoiceContext)
#
# 	# TODO - this could be more efficient: there are too many accesses to the Dictionary
#
# 	# if a sampler for this recursion depth is not already cached, create one and cache it
# 	if !haskey(s.cachedchildsamplers, cc.recursiondepth)
# 		s.cachedchildsamplers[cc.recursiondepth] = deepcopy(s.childsampler)
# 		depthchildparams = Float64[]
# 		for (idx, childparam) in enumerate(s.params[(s.numchildparams+1):end])
# 			push!(depthchildparams, childparam * (s.params[idx] ^ cc.recursiondepth))
# 		end
# 		setparams(s.cachedchildsamplers[cc.recursiondepth], depthchildparams)
# 	end
#
# 	# sample from the cached sampler
# 	godelnumber(s.cachedchildsamplers[cc.recursiondepth], cc)
#
# end

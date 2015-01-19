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

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


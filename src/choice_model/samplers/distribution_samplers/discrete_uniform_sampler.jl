#
# Discrete Uniform Distribution
#
# parameters:
# 	(1) a (lower bound)
#	(2) b (upper bound)
#

type DiscreteUniformDist <: DiscreteDist
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::DiscreteUniform
	function DiscreteUniformDist(params::Vector{Float64}=Float64[])
		s = new([(typemin(Int),typemax(Int)), (typemin(Int),typemax(Int))])
		# Distributions.DiscreteUniform only accommodates Int domain
		setparams(s, isempty(params) ? [typemin(Int), typemax(Int)] : params)
		s
	end
end

function setparams(s::DiscreteUniformDist, params::Vector{Float64})
	checkparamranges(s, params)
	# swap parameters if necessary (as a repair during search)
	if params[1] <= params[2]
		orderedparams = [params[1], params[2]]
	else
		orderedparams = [params[2], params[1]]
	end
	if orderedparams[1] == typemin(Int) && orderedparams[2] == typemax(Int)
		# if the entire Int domain,  Distributions.DiscreteUniform raises an error, so
		# here choose to adjust lower part of range to avoid the error
		warn("lower bound adjusted to typemin(Int)+1")
		orderedparams[1] = typemin(Int)+1
	end
	s.params = orderedparams
	s.distribution = DiscreteUniform(orderedparams[1], orderedparams[2])
end

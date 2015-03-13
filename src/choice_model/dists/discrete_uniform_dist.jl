#
# Discrete Uniform Distribution
#

type DiscreteUniformDist <: DiscreteDist
	lowerbound::Int64
	upperbound::Int64
	paramranges::Vector{(Float64,Float64)}
	params::Vector{Float64}
	distribution::DiscreteUniform
	supportlowerbound::Int64
	function DiscreteUniformDist(lowerbound::Integer, upperbound::Integer)
		lowerbound <= upperbound || error("lowerbound must be less than or equal to upperbound")
		# Distributions.DiscreteUniform only accommodates Int64 domain
		if upperbound > typemax(Int64)
			warn("upperbound adjusted to typemax(Int64)")
			upperbound = typemax(Int64)
		end
		if upperbound == typemax(Int64)
			if lowerbound < (typemin(Int64)+1)
				# additionally, if the entire Int64 domain,  Distributions.DiscreteUniform raises an error, so
				# here choose to adjust lower part of range to avoid the error
				warn("lowerbound adjusted to typemin(Int64)+1")
				lowerbound = typemin(Int64)+1
			end
		else
			if lowerbound < typemin(Int64)
				warn("lowerbound adjusted to typemin(Int64)")
				lowerbound = typemin(Int64)
			end
		end
		d = new(lowerbound, upperbound, (Float64,Float64)[])
		assignparams(d, Float64[])
		d
	end
end

function assignparams(d::DiscreteUniformDist, params::Vector{Float64}, check=true)
	d.params = params
	d.distribution = DiscreteUniform(d.lowerbound, d.upperbound)
	d.supportlowerbound = minimum(d.distribution)
end

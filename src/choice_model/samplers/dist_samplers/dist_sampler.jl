# a dist sampler is based directly on a probability distribution in the form a Dist
# therefore many methods at the sampler level simply pass through to the underlying Dist 
abstract DistSampler <: Sampler

numparams(ds::DistSampler) = numparams(ds.dist)

paramranges(ds::DistSampler) = paramranges(ds.dist)

setparams(ds::DistSampler, params::Vector{Float64}) = setparams(ds.dist, params)

getparams(ds::DistSampler) = getparams(ds.dist)

function godelnumber(ds::DistSampler,  cc::ChoiceContext)

	gn = cc.lowerbound

	if cc.lowerbound < cc.upperbound
		
		offset = 0
		if isfinite(ds.dist.supportlowerbound)
			offset = cc.lowerbound - supportlowerbound(ds.dist) 
		end

		# try up to 10 times to sample a valid godelnumber
		attempts = 0
		valid = false
		while (!valid) && (attempts <= 10)
			gn = sample(ds.dist) + offset
			if cc.lowerbound <= gn <= cc.upperbound
				valid = true
			end
			attempts += 1
		end
		
		# silently fall back to uniform	
		if !valid
			if typeof(ds.dist) <: DiscreteDist
				uniformdist = DiscreteUniformDist(cc.lowerbound, cc.upperbound)
			else
				uniformdist = UniformDist(cc.lowerbound, cc.upperbound)
			end
			gn = sample(uniformdist)
		end
	
	end

	gn

end

include("bernoulli_sampler.jl")
include("categorical_sampler.jl")
include("discrete_uniform_sampler.jl")
include("geometric_sampler.jl")
include("uniform_sampler.jl")
include("gaussian_sampler.jl")

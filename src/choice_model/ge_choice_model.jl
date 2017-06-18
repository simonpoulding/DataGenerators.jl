
type GEChoiceModel <: ChoiceModel
	genome::Vector{Int}
	activegene::Int
	function GEChoiceModel(genomelength::Int)
		genomelength > 0 || error("genome must have a length of 1 or more")
		new(fill(0.0, genomelength), 1)
	end
end

function GEChoiceModel(params::Vector)
	cm = GEChoiceModel(length(params))
	setparams!(cm, params)
	cm
end


function godelnumber(cm::GEChoiceModel, cc::ChoiceContext)
	
	# wrap to beginning of genome if necessary
	if cm.activegene > length(cm.genome)
		cm.activegene = 1
	end

	allele = cm.genome[cm.activegene]
	@assert allele >= 0
	
	# println("Choice Context: $(cc.lowerbound), $(cc.upperbound)")
	# println("Allele: $(allele)")
	
	gn = if (cc.datatype <: Bool) || (cc.datatype <: Integer ? (cc.lowerbound > typemin(cc.datatype)) : isfinite(cc.lowerbound))
			if (cc.datatype <: Bool) || (cc.datatype <: Integer ? (cc.upperbound < typemax(cc.datatype)) : isfinite(cc.upperbound))
				# println("both finite")
				cc.lowerbound + mod(allele, cc.upperbound - cc.lowerbound + ((cc.datatype <: Integer) ? 1 : 0.0))
			else
				# println("lower finite; upper infinite")
				cc.lowerbound + allele
			end
		else
			if (cc.datatype <: Integer ? (cc.upperbound < typemax(cc.datatype)) : isfinite(cc.upperbound))
				# println("lower infinite; upper finite")
				cc.upperbound - allele
			else
				# println("lower infinite; upper infinite")
				allele
			end
		end
	
	cptrace = Dict{Symbol, Any}(:all => allele, :gen => cm.activegene)

	cm.activegene += 1

	# println("GN: $(gn)")
	
	convert(cc.datatype, gn), cptrace
	
end


function resetstate!(cm::GEChoiceModel)
	cm.activegene = 1
end


getparams(cm::GEChoiceModel) = convert(Vector{Float64}, cm.genome)

function setparams!(cm::GEChoiceModel, params)
	length(params) == length(cm.genome) || error("Expected $(length(cm.genome)) parameters, but got $(length(params))")
	all(p -> 0<=p<=Float64(typemax(UInt32)), params) || error("All parameters must be between 0 and $(typemax(UInt32))") 
	cm.genome = map(p->Int(round(p)), params)
end

paramranges(cm::GEChoiceModel) = fill((Float64(0),Float64(typemax(UInt32))), length(cm.genome))

show(io::IO, cm::GEChoiceModel) = print(io, "Grammmatical Evolution choice model (genome: ", cm.genome, ")")
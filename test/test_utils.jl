# find midpoint of a range without causing an overflow to Inf
function robustmidpoint(a::Float64,b::Float64)
	l = min(a,b)
	u = max(a,b)
	if sign(l) == sign(u)
		m = l + (u-l)/2
	else
		m = (u+l)/2
	end
	m
end



# used mainly to adjust parameters of Geometric distribution away from boundary values
function adjusttoopeninterval(p, lower, upper)
	if p == lower
		p += 0.00001
	end
	if p == upper
		p -= 0.00001
	end
	p
end



#
# dummy DerivationState, Choice Context etc. to facilitate testing of internal choice model functions
#
import DataGenerators: getcurrentrecursiondepth, getimmediateancestorcpseqnumber, godelnumber

# for all apart from the ConditionalSampler, the choice context is not required
type DummyDerivationState <: DataGenerators.DerivationState
end

# required for sampler choice model
getcurrentrecursiondepth(st::DummyDerivationState) = 1
getimmediateancestorcpseqnumber(st::DummyDerivationState) = 0

dummyChoiceContext() = DataGenerators.ChoiceContext(DummyDerivationState(), :rule, 0, Int, 0, 0)



# choice model that only returns the lower bound Godel number (used to test generator)
type MinimumValueChoiceModel <: DataGenerators.ChoiceModel; end
function godelnumber(cm::MinimumValueChoiceModel, cc::DataGenerators.ChoiceContext)
	return cc.lowerbound, Dict()
end


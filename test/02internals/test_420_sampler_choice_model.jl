# tests sampler choice model

using GodelTest
using HypothesisTests

@generator SCMGen begin # prefix SCM (for Sampler Choice Model) to avoid type name clashes
	start() = reps(a,1+1,2+2) # non-literal arguments to allow us to pass range to godelnumber during testing
	a() = choose(Int,-2-2,1+1)
	a() = choose(Float64,-2.0-2.0,1.0+1.0)
	a() = choose(Bool)
end

@generator SCMRepsGen begin
	start() = reps(a,1+1,2+2) # non-literal arguments to allow us to pass range to godelnumber during testing
	a() = 'a'
end

@generator SCMChooseBoolGen begin
	start() = choose(Bool) # 
end

@generator SCMChooseIntGen begin
	start() = choose(Int,-2-2,1+1) # non-literal arguments to allow us to pass range to godelnumber during testing
end

@generator SCMChooseFloat64Gen begin
	start() = choose(Float64,-2.0-2.0,1.0+1.0) # non-literal arguments to allow us to pass range to godelnumber during testing
end

@generator SCMRuleGen begin
	start() = x()
	x() = 'a'
	x() = 'b'
	x() = 'c'
	x() = 'd'
end

# internally will use range of choice points, so convenient for testing choice model when more than one choice point
@generator SCMChooseStringGen begin
	start() = choose(ASCIIString,"a(b|c)d+ef?")
end


describe("sampler choice model constructor") do

	test("constructor - generator as a parameter") do
		gn = SCMGen()
		cm = SamplerChoiceModel(gn)
		@check typeof(cm) == SamplerChoiceModel
	end

end

# basic tests of parameter functionality; more specific tests using single choice point generators below
describe("sampler choice model - set/get parameters and ranges") do

	gn = SCMGen()
	cm = SamplerChoiceModel(gn)

	test("paramranges") do
		ranges = paramranges(cm)
		@check typeof(ranges) <: Vector{(Float64,Float64)}
		@check length(ranges) == 5
	end

	test("getparams") do
		params = getparams(cm)
		@check typeof(params) <: Vector{Float64}
		@check length(params) == 5
	end

	test("setparams") do
		newparams = [(paramrange[1]+paramrange[2])/2 for paramrange in paramranges(cm)]
		setparams(cm, newparams)
		@check length(getparams(cm)) == 5 # can't check equality of params since some adjustment can be made by the cm
	end

end

describe("sampler choice model - rule choice point") do

	gn = SCMRuleGen()
	cm = SamplerChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))
	
	# type ChoiceContext
	# 	derivationstate::DerivationState
	# 	cptype::Symbol
	# 	cpid::Uint64
	# 	datatype::DataType
	# 	lowerbound::Real
	# 	upperbound::Real
	# end
	cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.RULE_CP, cpids[1], Int, 1, 4)

	@repeat test("valid Godel numbers returned") do
		gnum, trace = GodelTest.godelnumber(cm, cc)
		@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
		@mcheck_values_are gnum [1,2,3,4]
	end
	
	test("sampler uses a Categorical distribution") do
		@check length(cm.samplers) == 1
		sampler = first(values(cm.samplers))
		@check typeof(sampler) <: GodelTest.CategoricalSampler
	end

	test("get and set sampler parameters") do
		sampler = first(values(cm.samplers))
		@check getparams(cm) == [0.25,0.25,0.25,0.25,]
		@check paramranges(cm) == [(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),]
		setparams(cm,[0.03,0.03,0.01,0.01])
		@check round(getparams(cm),4) == [0.375,0.375,0.125,0.125,] # round to avoid precision errors
	end
		
end

describe("sampler choice model - sequence choice point") do

	gn = SCMRepsGen()
	cm = SamplerChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))
	
	describe("small finite range") do 
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.SEQUENCE_CP, cpids[1], Int64, 0, 2)
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check 0 <= gnum <= 2
			@mcheck_values_are gnum [0,1,2]
		end

	end

	describe("large finite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.SEQUENCE_CP, cpids[1], Int64, 11, 16)
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check 11 <= gnum <= 16
			@mcheck_values_include gnum [11,13,16]
		end
		
	end

	describe("semi-finite range") do

		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.SEQUENCE_CP, cpids[1], Int64, 1, typemax(Int64))

		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check 1 <= gnum <= typemax(Int64)
			@mcheck_values_vary gnum
		end
		
	end
	
	describe("sampler") do

		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.SEQUENCE_CP, cpids[1], Int64, 7, typemax(Int64))

		test("sampler consistent with a offset geometric distribution") do
			xs = map(i->first(GodelTest.godelnumber(cm, cc)), 1:100)
			ys = cc.lowerbound + rand(Distributions.Geometric(0.5), 100)
			@check pvalue(MannWhitneyUTest(xs,ys)) > 0.0001			
		end
	
		test("get and set sampler parameters") do
			sampler = first(values(cm.samplers))
			@check getparams(cm) == [0.5,]
			@check paramranges(cm) == [(0.0,1.0),]
			setparams(cm,[0.6])
			@check getparams(cm) == [0.6,]
		end

	end
	
end


describe("sampler choice model - Bool value choice point") do

	gn = SCMChooseBoolGen()
	cm = SamplerChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))

	cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Bool, false, true)
	
	@repeat test("valid Godel numbers returned") do
		gnum, trace = GodelTest.godelnumber(cm, cc)
		@check convert(Bool,gnum) != nothing  # raises exception if value can't be converted
		@mcheck_values_are gnum [false,true]
	end

	test("sampler consistent with a Bernoulli distribution") do
		xs = map(i->first(GodelTest.godelnumber(cm, cc)), 1:100)
		ys = rand(Distributions.Bernoulli(0.5), 100)
		@check pvalue(MannWhitneyUTest(xs,ys)) > 0.0001			
	end

	test("get and set sampler parameters") do
		sampler = first(values(cm.samplers))
		@check getparams(cm) == [0.5,]
		@check paramranges(cm) == [(0.0,1.0),]
		setparams(cm,[0.6])
		@check getparams(cm) == [0.6,]
	end
	
end


describe("sampler choice model - Int64 value choice point") do

	gn = SCMChooseIntGen()
	cm = SamplerChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))
	
	describe("small finite range") do

		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int64, -1, 2)

		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check -1 <= gnum <= 2
			@mcheck_values_are gnum [-1,0,1,2]
		end
		
	end

	describe("large finite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int64, 11, 16)
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check 11 <= gnum <= 16
			@mcheck_values_include gnum [11,13,16] # just a selection of possible values including end points
		end
		
	end

	describe("semi-finite range (upper)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int64, 128, typemax(Int64))
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check 128 <= gnum <= typemax(Int64)
			@mcheck_values_vary gnum
		end
		
	end

	describe("semi-finite range (lower)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int64, typemin(Int64), 128)
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check typemin(Int64) <= gnum <= 128
			@mcheck_values_vary gnum
		end
		
	end

	describe("infinite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int64, typemin(Int64), typemax(Int64))
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Int64,gnum) != nothing  # raises exception if value can't be converted
			@check typemin(Int64) <= gnum <= typemax(Int64)
			@mcheck_values_vary gnum
		end
		
	end
	
	describe("sampler") do
		
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, 29, 301)

		test("sampler consistent with a discrete uniform distribution") do
			xs = map(i->first(GodelTest.godelnumber(cm, cc)), 1:100)
			ys = rand(Distributions.DiscreteUniform(cc.lowerbound, cc.upperbound), 100)
			@check pvalue(MannWhitneyUTest(xs,ys)) > 0.0001			
		end

		test("get and set sampler parameters") do
			sampler = first(values(cm.samplers))
			@check getparams(cm) == []
			@check paramranges(cm) == []
		end

	end
	
end


describe("sampler choice model - Float64 value choice point") do

	gn = SCMChooseFloat64Gen()
	cm = SamplerChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))
	
	describe("finite range") do

		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, -42.2, -8.7)

		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			@check -42.2 <= gnum <= -8.7
			@mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end

	describe("semi-finite range (upper)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, 450001.6, Inf)
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			@check 450001.6 <= gnum
			# @mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end

	describe("semi-finite range (lower)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, -Inf, 450001.6)
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			@check gnum <= 450001.6
			# @mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end

	describe("infinite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, -Inf, Inf)
		
		@repeat test("valid Godel numbers returned") do
			gnum, trace = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			# @mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end
	
	describe("sampler") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, -180.7, 123.728)

		test("sampler consistent with a uniform distribution") do
			xs = map(i->first(GodelTest.godelnumber(cm, cc)), 1:100)
			ys = rand(Distributions.Uniform(cc.lowerbound, cc.upperbound), 100)
			@check pvalue(MannWhitneyUTest(xs,ys)) > 0.0001			
		end

		test("get and set sampler parameters") do
			sampler = first(values(cm.samplers))
			@check getparams(cm) == []
			@check paramranges(cm) == []
		end
		
	end
	
end

describe("sampler choice model - generate for model with multiple choice points") do

	gn = SCMChooseStringGen()
	cm = SamplerChoiceModel(gn)
	
	@repeat test("full range of values generated using choice model") do
		td = gen(gn, choicemodel=cm)
		@check ismatch(r"^a(b|c)d+ef?$", td)
		@mcheck_values_include count(x->x=='d', td) [1,2,3]
		@mcheck_values_are td[2] ['b','c']
		@mcheck_values_are td[end] ['e','f']
	end

end

describe("sampler choice model - non-default mapping") do

	gn = SCMRuleGen()
	
	function nondefaultmapping(info::Dict)
		cptype = info[:type]
		if cptype == GodelTest.RULE_CP
			sampler = GodelTest.DiscreteUniformSampler()
		elseif cptype == GodelTest.SEQUENCE_CP
			sampler = GodelTest.GeometricSampler()
		elseif cptype == GodelTest.VALUE_CP
			datatype = info[:datatype]
			if datatype <: Bool
				sampler = GodelTest.BernoulliSampler()
			elseif datatype <: Integer # order of if clauses matters here since Bool <: Integer
				sampler = GodelTest.DiscreteUniformSampler()
			else # floating point, but may also be a rational type
				sampler = GodelTest.UniformSampler()
			end
		else
			error("unrecognised choice point type when creating non-default choice model")
		end
	end

	cm = SamplerChoiceModel(gn, choicepointmapping=nondefaultmapping)
	
	@check length(cm.samplers) == 1
	sampler = first(values(cm.samplers))
	@check typeof(sampler) <: GodelTest.DiscreteUniformSampler
		
end


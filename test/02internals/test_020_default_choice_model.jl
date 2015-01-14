# tests default choice model

using GodelTest

@generator DCMGen begin # prefix DCM (for Default Choice Model) to avoid type name clashes
	start() = reps(a,1+1,2+2) # non-literal arguments to allow us to pass range to godelnumber during testing
	a() = choose(Int,-2-2,1+1)
	a() = choose(Float64,-2.0-2.0,1.0+1.0)
	a() = choose(Bool)
end

@generator DCMRepsGen begin
	start() = reps(a,1+1,2+2) # non-literal arguments to allow us to pass range to godelnumber during testing
	a() = 'a'
end

@generator DCMChooseBoolGen begin
	start() = choose(Bool) # 
end

@generator DCMChooseIntGen begin
	start() = choose(Int,-2-2,1+1) # non-literal arguments to allow us to pass range to godelnumber during testing
end

@generator DCMChooseFloat64Gen begin
	start() = choose(Float64,-2.0-2.0,1.0+1.0) # non-literal arguments to allow us to pass range to godelnumber during testing
end

@generator DCMRuleGen begin
	start() = x()
	x() = 'a'
	x() = 'b'
	x() = 'c'
	x() = 'd'
end

# internally will use range of choice points, so convenient for testing choice model when more than one choice point
@generator DCMChooseStringGen begin
	start() = choose(ASCIIString,"a(b|c)d+ef?")
end

describe("default choice model constructor") do

	test("constructor - generator as a parameter") do
		gn = DCMGen()
		cm = DefaultChoiceModel(gn)
		@check typeof(cm) == DefaultChoiceModel
	end

end

describe("default choice model - set/get parameters and ranges") do

	gn = DCMGen()
	cm = DefaultChoiceModel(gn)

	test("paramranges") do
		ranges = paramranges(cm)
		@check typeof(ranges) <: Vector
		@check length(ranges) == 0
	end

	test("getparams") do
		params = getparams(cm)
		@check typeof(params) <: Vector
		@check length(params) == 0
	end

	test("setparams") do
		newparams = [(paramrange[1]+paramrange[2])/2 for paramrange in paramranges(cm)]
		setparams(cm, newparams)
		@check length(getparams(cm)) == 0 # can't check equality of params since some adjustment can be made by the cm
	end

end

describe("default choice model - rule choice point") do

	gn = DCMRuleGen()
	cm = DefaultChoiceModel(gn)
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
		gnum = GodelTest.godelnumber(cm, cc)
		@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
		@mcheck_values_are gnum [1,2,3,4]
	end
		
end

describe("default choice model - sequence choice point") do

	gn = DCMRepsGen()
	cm = DefaultChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))
	
	describe("small finite range") do 
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.SEQUENCE_CP, cpids[1], Int, 0, 2)
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check 0 <= gnum <= 2 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
			@mcheck_values_are gnum [0,1,2]
		end

	end

	describe("large finite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.SEQUENCE_CP, cpids[1], Int, 11, 16)
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check 11 <= gnum <= 13 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
			@mcheck_values_are gnum [11,12,13]
		end
		
	end

	describe("semi-finite range") do

		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.SEQUENCE_CP, cpids[1], Int, 1, typemax(Int))

		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check 1 <= gnum <= 3 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
			@mcheck_values_are gnum [1,2,3]
		end
		
	end
	
end


describe("default choice model - Bool value choice point") do

	gn = DCMChooseBoolGen()
	cm = DefaultChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))

	cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Bool, false, true)
	
	@repeat test("valid Godel numbers returned") do
		gnum = GodelTest.godelnumber(cm, cc)
		@check convert(Bool,gnum) != nothing  # raises exception if value can't be converted
		@mcheck_values_are gnum [false,true]
	end

end


describe("default choice model - Int value choice point") do

	gn = DCMChooseIntGen()
	cm = DefaultChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))
	
	describe("small finite range") do

		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int, -1, 2)

		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check -1 <= gnum <= 2
			@mcheck_values_are gnum [-1,0,1,2]
		end
		
	end

	describe("large finite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int, 11, 16)
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check 11 <= gnum <= 16
			@mcheck_values_include gnum [11,13,16] # just a selection of possible values including end points
		end
		
	end

	describe("semi-finite range (upper)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int, 128, typemax(Int))
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check 128 <= gnum <= typemax(Int)
			@mcheck_values_vary gnum
		end
		
	end

	describe("semi-finite range (lower)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int, typemin(Int), 128)
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check typemin(Int) <= gnum <= 128
			@mcheck_values_vary gnum
		end
		
	end

	describe("infinite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Int, typemin(Int), typemax(Int))
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Int,gnum) != nothing  # raises exception if value can't be converted
			@check typemin(Int) <= gnum <= typemax(Int)
			@mcheck_values_vary gnum
		end
		
	end
	
end


describe("default choice model - Float64 value choice point") do

	gn = DCMChooseFloat64Gen()
	cm = DefaultChoiceModel(gn)
	cpi = choicepointinfo(gn)
	cpids = collect(keys(cpi))
	
	describe("finite range") do

		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, -42.2, -8.7)

		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			@check -42.2 <= gnum <= -8.7
			@mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end

	describe("semi-finite range (upper)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, 450001.6, Inf)
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			@check 450001.6 <= gnum
			@mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end

	describe("semi-finite range (lower)") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, -Inf, 450001.6)
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			@check gnum <= 450001.6
			@mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end

	describe("infinite range") do
	
		cc = GodelTest.ChoiceContext(GodelTest.DefaultDerivationState(gn, cm, 10000), GodelTest.VALUE_CP, cpids[1], Float64, -Inf, Inf)
		
		@repeat test("valid Godel numbers returned") do
			gnum = GodelTest.godelnumber(cm, cc)
			@check convert(Float64,gnum) != nothing  # raises exception if value can't be converted
			@mcheck_that_sometimes int(gnum) != gnum
			@mcheck_values_vary gnum
		end
		
	end
	
end

describe("default choice model - generate for model with multiple choice points") do

	gn = DCMChooseStringGen()
	cm = DefaultChoiceModel(gn)
	
	@repeat test("full range of values generated using choice model") do
		td = gen(gn, choicemodel=cm)
		@check ismatch(r"^a(b|c)d+ef?$", td)
		@mcheck_values_include count(x->x=='d', td) [1,2,3]
		@mcheck_values_are td[2] ['b','c']
		@mcheck_values_are td[end] ['e','f']
	end

end

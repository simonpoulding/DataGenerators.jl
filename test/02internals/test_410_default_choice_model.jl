# tests default choice model

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

@testset "default choice model constructor" begin

@testset "constructor - generator as a parameter" begin
    gn = DCMGen()
    cm = DefaultChoiceModel(gn)
    @test typeof(cm) == DefaultChoiceModel
end

end

@testset "default choice model - set/get parameters and ranges" begin

gn = DCMGen()
cm = DefaultChoiceModel(gn)

@testset "paramranges" begin
    # TBD: Fix test, cannot find paramranges function...
    #ranges = paramranges(cm)
    #@test typeof(ranges) <: Vector
    #@test length(ranges) == 0
end

@testset "getparams" begin
    params = getparams(cm)
    @test typeof(params) <: Vector
    @test length(params) == 0
end

@testset "setparams" begin
    #newparams = [(paramrange[1]+paramrange[2])/2 for paramrange in paramranges(cm)]
    #setparams(cm, newparams)
    #@test length(getparams(cm)) == 0 # can't check equality of params since some adjustment can be made by the cm
end

end

@testset "default choice model - rule choice point" begin

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
cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.RULE_CP, cpids[1], Int, 1, 4)

@testset "valid Godel numbers returned" for i in 1:NumReps 
    gnum, trace = DataGenerators.godelnumber(cm, cc)
    @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
    @mcheck_values_are gnum [1,2,3,4]
end
		
end

@testset "default choice model - sequence choice point" begin

gn = DCMRepsGen()
cm = DefaultChoiceModel(gn)
cpi = choicepointinfo(gn)
cpids = collect(keys(cpi))
	
@testset "small finite range" begin 
	
cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.SEQUENCE_CP, cpids[1], Int, 0, 2)
		
@testset "valid Godel numbers returned" begin
    gnum, trace = DataGenerators.godelnumber(cm, cc)
    @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
    @test 0 <= gnum <= 2 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
    @mcheck_values_are gnum [0,1,2]
end

end

@testset "large finite range" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.SEQUENCE_CP, cpids[1], Int, 11, 16)
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
        @test 11 <= gnum <= 13 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
        @mcheck_values_are gnum [11,12,13]
    end
		
end

@testset "semi-finite range" begin

    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.SEQUENCE_CP, cpids[1], Int, 1, typemax(Int))

    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
        @test 1 <= gnum <= 3 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
        @mcheck_values_are gnum [1,2,3]
    end

end
	
end


@testset "default choice model - Bool value choice point" begin

gn = DCMChooseBoolGen()
cm = DefaultChoiceModel(gn)
cpi = choicepointinfo(gn)
cpids = collect(keys(cpi))

cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Bool, false, true)
	
@testset "valid Godel numbers returned" begin
    gnum, trace = DataGenerators.godelnumber(cm, cc)
    @test convert(Bool,gnum) != nothing  # raises exception if value can't be converted
    @mcheck_values_are gnum [false,true]
end

end


@testset "default choice model - Int value choice point" begin

gn = DCMChooseIntGen()
cm = DefaultChoiceModel(gn)
cpi = choicepointinfo(gn)
cpids = collect(keys(cpi))
	
@testset "small finite range" begin

    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Int, -1, 2)

    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
        @test -1 <= gnum <= 2
        @mcheck_values_are gnum [-1,0,1,2]
    end
		
end

@testset "large finite range" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Int, 11, 16)
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
        @test 11 <= gnum <= 16
        @mcheck_values_include gnum [11,13,16] # just a selection of possible values including end points
    end
		
end

@testset "semi-finite range (upper)" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Int, 128, typemax(Int))
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
        @test 128 <= gnum <= typemax(Int)
        @mcheck_values_vary gnum
    end
		
end

@testset "semi-finite range (lower)" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Int, typemin(Int), 128)
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
        @test typemin(Int) <= gnum <= 128
        @mcheck_values_vary gnum
    end
		
end

@testset "infinite range" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Int, typemin(Int), typemax(Int))
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
        @test typemin(Int) <= gnum <= typemax(Int)
        @mcheck_values_vary gnum
    end
		
end
	
end


@testset "default choice model - Float64 value choice point" begin

gn = DCMChooseFloat64Gen()
cm = DefaultChoiceModel(gn)
cpi = choicepointinfo(gn)
cpids = collect(keys(cpi))
	
@testset "finite range" begin

    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Float64, -42.2, -8.7)

    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
        @test -42.2 <= gnum <= -8.7
        @mcheck_that_sometimes int(gnum) != gnum
        @mcheck_values_vary gnum
    end
		
end

@testset "semi-finite range (upper)" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Float64, 450001.6, Inf)
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
        @test 450001.6 <= gnum
        @mcheck_that_sometimes int(gnum) != gnum
        @mcheck_values_vary gnum
    end
		
end

@testset "semi-finite range (lower)" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Float64, -Inf, 450001.6)
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
        @test gnum <= 450001.6
        @mcheck_that_sometimes int(gnum) != gnum
        @mcheck_values_vary gnum
    end
		
end

@testset "infinite range" begin
	
    cc = DataGenerators.ChoiceContext(DataGenerators.DefaultDerivationState(gn, cm, 10000), DataGenerators.VALUE_CP, cpids[1], Float64, -Inf, Inf)
		
    @testset "valid Godel numbers returned" begin
        gnum, trace = DataGenerators.godelnumber(cm, cc)
        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
        @mcheck_that_sometimes int(gnum) != gnum
        @mcheck_values_vary gnum
    end
		
end
	
end

@testset "default choice model - generate for model with multiple choice points" begin

gn = DCMChooseStringGen()
cm = DefaultChoiceModel(gn)
	
@testset "full range of values generated using choice model" begin
    td = choose(gn, choicemodel=cm)
    @test ismatch(r"^a(b|c)d+ef?$", td)
    @mcheck_values_include count(x->x=='d', td) [1,2,3]
    @mcheck_values_are td[2] ['b','c']
    @mcheck_values_are td[end] ['e','f']
end

end

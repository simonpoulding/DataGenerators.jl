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
    start() = choose(String,"a(b|c)d+ef?")
end


@testset "default choice model" begin

	@testset "constructor" begin

	    gn = DCMGen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)
	    @test typeof(cm) == DataGenerators.SimpleChoiceModel

	end

	@testset "set/get parameters and ranges" begin

		gn = DCMGen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)

		@testset "paramranges" begin
		    ranges = paramranges(cm)
		    @test typeof(ranges) <: Vector{Tuple{Float64,Float64}}
		    @test length(ranges) == 0
		end

		@testset "getparams" begin
		    params = getparams(cm)
		    @test typeof(params) <: Vector{Float64}
		    @test length(params) == 0
		end

		@testset "setparams" begin
		    newparams = [(paramrange[1]+paramrange[2])/2 for paramrange in paramranges(cm)]
		    setparams!(cm, newparams)
		    @test length(getparams(cm)) == 0 # can't check equality of params since some adjustment can be made by the cm
		end

	end

	@testset "rule choice point" begin

		gn = DCMRuleGen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)
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
		cc = DataGenerators.ChoiceContext(DummyDerivationState(), :rule, cpids[1], Int, 1, 4)

		@mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		    gnum, trace = DataGenerators.godelnumber(cm, cc)
		    @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		    @mtest_values_are [1,2,3,4] gnum
		end
		
	end

	@testset "sequence choice point" begin

		gn = DCMRepsGen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))
	
		@testset "small finite range" begin 
	
			cc = DataGenerators.ChoiceContext(DummyDerivationState(), :sequence, cpids[1], Int, 0, 2)
		
			@mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
			    gnum, trace = DataGenerators.godelnumber(cm, cc)
			    @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
			    @test 0 <= gnum <= 2 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
			    @mtest_values_are [0,1,2] gnum
			end

		end

		@testset "large finite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :sequence, cpids[1], Int, 11, 16)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 11 <= gnum <= 13 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
		        @mtest_values_are [11,12,13] gnum
		    end
		
		end

		@testset "semi-finite range" begin

		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :sequence, cpids[1], Int, 1, typemax(Int))

		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 1 <= gnum <= 3 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
		        @mtest_values_are [1,2,3] gnum
		    end

		end
	
	end

	@testset "Bool value choice point" begin

		gn = DCMChooseBoolGen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))

		cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Bool, false, true)
	
		@mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		    gnum, trace = DataGenerators.godelnumber(cm, cc)
		    @test convert(Bool,gnum) != nothing  # raises exception if value can't be converted
		    @mtest_values_are [false,true] gnum
		end

	end


	@testset "Int value choice point" begin

		gn = DCMChooseIntGen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))
	
		@testset "small finite range" begin

		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Int, -1, 2)

		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test -1 <= gnum <= 2
		        @mtest_values_are [-1,0,1,2] gnum
		    end
		
		end

		@testset "large finite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Int, 11, 16)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 11 <= gnum <= 16
		        @mtest_values_include [11,13,16] gnum # just a selection of possible values including end points 
		    end
		
		end

		@testset "semi-finite range (upper)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Int, 128, typemax(Int))
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 128 <= gnum <= typemax(Int)
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "semi-finite range (lower)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Int, typemin(Int), 128)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test typemin(Int) <= gnum <= 128
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "infinite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Int, typemin(Int), typemax(Int))
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test typemin(Int) <= gnum <= typemax(Int)
		        @mtest_values_vary gnum
		    end
		
		end
	
	end


	@testset "Float64 value choice point" begin

		gn = DCMChooseFloat64Gen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))
	
		@testset "finite range" begin

		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Float64, -42.2, -8.7)

		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @test -42.2 <= gnum <= -8.7
		        @mtest_that_sometimes round(gnum) != gnum
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "semi-finite range (upper)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Float64, 450001.6, Inf)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @test 450001.6 <= gnum
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "semi-finite range (lower)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Float64, -Inf, 450001.6)
		
		    @mtestset "valid Godel numbers returned" begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @test gnum <= 450001.6
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "infinite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), :value, cpids[1], Float64, -Inf, Inf)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS alpha=Main.ALPHA begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @mtest_values_vary gnum
		    end
		
		end
	
	end

	@testset "generate for model with multiple choice points" begin

		gn = DCMChooseStringGen()
		setchoicemodel!(gn, SimpleChoiceModel())
	    cm = choicemodel(gn)
	
		@mtestset "full range of values generated using choice model" reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn, choicemodel=cm)
		    @test ismatch(r"^a(b|c)d+ef?$", td)
		    @mtest_values_include [1,2,3] count(x->x=='d', td)
		    @mtest_values_are ['b','c'] td[2]
		    @mtest_values_are ['e','f'] td[end]
		end

	end

end

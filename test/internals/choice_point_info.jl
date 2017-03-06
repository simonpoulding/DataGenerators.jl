# tests information stored as choice point info

#
# sequence choice points
#

@generator CPRepsLiteralMinMaxGen begin # prefix CP (for Choice Point info) to avoid type name clashes
    start() = reps(a,2,4)
    a() = gensym()
end

@generator CPRepsNonLiteralMinGen begin
    start() = reps(a,1+1,4)
    a() = gensym()
end

@generator CPRepsNonLiteralMaxGen begin
    start() = reps(a,2,2+2)
    a() = gensym()
end

@generator CPRepsNonLiteralMinMaxGen begin
    start() = reps(a,1+1,2+2)
    a() = gensym()
end

@generator CPRepsNoMaxGen begin
    start() = reps(a,2)
    a() = gensym()
end

@generator CPMultGen begin
    start() = mult(a)
    a() = gensym()
end

@generator CPPlusGen begin
    start() = plus(a)
    a() = gensym()
end

@generator CPRuleGen begin
    start() = x()
    x() = 'a'
    x() = 'b'
    x() = 'c'
end

@generator CPChooseIntLiteralMinMaxGen begin
    start() = choose(Int,2,4)
end

@generator CPChooseIntNonLiteralMinGen begin
    start() = choose(Int,1+1,4)
end

@generator CPChooseIntNonLiteralMaxGen begin
    start() = choose(Int,2,2+2)
end

@generator CPChooseIntNonLiteralMinMaxGen begin
    start() = choose(Int,1+1,2+2)
end

@generator CPChooseIntNoMaxGen begin
    start() = choose(Int,2)
end

@generator CPChooseIntNoMinMaxGen begin
    start() = choose(Int)
end

@generator CPChooseFloat64LiteralMinMaxGen begin
    start() = choose(Float64,2.1,4.2)
end

@generator CPChooseBoolGen begin
    start() = choose(Bool)
end

@generator CPMultipleCPGen begin
    start() = mult(a)
    a() = choose(Int,2,4)
    a() = 'a'
end

@generator CPBoolGen begin
    start() = choose(Bool)
end

@generator CPIntGen begin
    start() = choose(Int,5,9)
end

@generator CPMainGen(boolGen, intGen) begin
    start() = map(i->choose(boolGen), 1:choose(intGen))
end



@testset "choice point info" begin

	@testset "sequence choice point info" begin

		@testset "reps with literal min and max" begin
		    gn = CPRepsLiteralMinMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.SEQUENCE_CP
		    @test cp1[:min] == 2
		    @test cp1[:max] == 4
		end

		@testset "reps with non-literal min" begin
		    gn = CPRepsNonLiteralMinGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.SEQUENCE_CP
		    @test !haskey(cp1,:min)
		    @test cp1[:max] == 4
		end

		@testset "reps with non-literal max" begin
		    gn = CPRepsNonLiteralMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.SEQUENCE_CP
		    @test cp1[:min] == 2
		    @test !haskey(cp1,:max)
		end

		@testset "reps with non-literal min and max" begin
		    gn = CPRepsNonLiteralMinMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.SEQUENCE_CP
		    @test !haskey(cp1,:min)
		    @test !haskey(cp1,:max)
		end

		@testset "reps with no max" begin
		    gn = CPRepsNoMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.SEQUENCE_CP
		    @test cp1[:min] == 2
		    @test cp1[:max] == typemax(Int)
		end

		@testset "mult" begin
		    gn = CPMultGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.SEQUENCE_CP
		    @test cp1[:min] == 0
		    @test cp1[:max] == typemax(Int)
		end

		@testset "plus" begin
		    gn = CPPlusGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.SEQUENCE_CP
		    @test cp1[:min] == 1
		    @test cp1[:max] == typemax(Int)
		end
	
	end

	@testset "rule choice point info" begin

		@testset "rule choice" begin
		    gn = CPRuleGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.RULE_CP
		    @test cp1[:min] == 1
		    @test cp1[:max] == 3
		    @test cp1[:rulename] == :x
		end
	
	end

	@testset "value choice point info" begin

		@testset "choose Int with literal min and max" begin
		    gn = CPChooseIntLiteralMinMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Int
		    @test cp1[:min] == 2
		    @test cp1[:max] == 4
		end

		@testset "choose Int with non literal min" begin
		    gn = CPChooseIntNonLiteralMinGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Int
		    @test !haskey(cp1,:min)
		    @test cp1[:max] == 4
		end

		@testset "choose Int with non literal max" begin
		    gn = CPChooseIntNonLiteralMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Int
		    @test cp1[:min] == 2
		    @test !haskey(cp1,:max)
		end

		@testset "choose Int with non literal min and max" begin
		    gn = CPChooseIntNonLiteralMinMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Int
		    @test !haskey(cp1,:min)
		    @test !haskey(cp1,:max)
		end

		@testset "choose Int with no max" begin
		    gn = CPChooseIntNoMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Int
		    @test cp1[:min] == 2
		    @test cp1[:max] == typemax(Int)
		end

		@testset "choose Int with no min nor max" begin
		    gn = CPChooseIntNoMinMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Int
		    @test cp1[:min] == typemin(Int)
		    @test cp1[:max] == typemax(Int)
		end

		@testset "choose Float64 with literal min and max" begin
		    gn = CPChooseFloat64LiteralMinMaxGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Float64
		    @test cp1[:min] == 2.1
		    @test cp1[:max] == 4.2
		end

		@testset "choose Bool" begin
		    gn = CPChooseBoolGen()
		    cpi = gn.choicepointinfo
		    cpids = collect(keys(cpi))
		    @test length(cpi) == 1
		    cp1 = cpi[cpids[1]]
		    @test cp1[:type] == DataGenerators.VALUE_CP
		    @test cp1[:datatype] == Bool
		    @test cp1[:min] == false
		    @test cp1[:max] == true
		end

	end

	@testset "multiple choice points" begin

		@testset "generator sequence, rule, and value choice points" begin
		    gn = CPMultipleCPGen()
		    cpi = gn.choicepointinfo
		    @test length(cpi) == 3
		    cptypes = [cpdict[:type] for cpdict in values(cpi)]
		    @test DataGenerators.SEQUENCE_CP in cptypes
		    @test DataGenerators.RULE_CP in cptypes
		    @test DataGenerators.VALUE_CP in cptypes
		end
	
	end

	@testset "choicepointinfo function" begin

		@testset "returns info for the generator itself when no subgenerators" begin
		    gn = CPMultipleCPGen()
		    cpi = gn.choicepointinfo
		    @test choicepointinfo(gn) == cpi
		end

		@testset "returns info for the generator and the subgenerators when one or more subgenerators" begin
		    bgn = CPBoolGen()
		    ign = CPIntGen()
		    gn = CPMainGen(bgn,ign)
		    bcpi = bgn.choicepointinfo
		    icpi = ign.choicepointinfo
		    cpi = gn.choicepointinfo
		    @test choicepointinfo(gn) == merge(cpi,bcpi,icpi)
		end

	end

end

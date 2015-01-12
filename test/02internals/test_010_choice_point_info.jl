# tests information stored as choice point info

using GodelTest

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


describe("sequence choice point info") do

	test("reps with literal min and max") do
		gn = CPRepsLiteralMinMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.SEQUENCE_CP
		@check cp1[:min] == 2
		@check cp1[:max] == 4
	end

	test("reps with non-literal min") do
		gn = CPRepsNonLiteralMinGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.SEQUENCE_CP
		@check !haskey(cp1,:min)
		@check cp1[:max] == 4
	end

	test("reps with non-literal max") do
		gn = CPRepsNonLiteralMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.SEQUENCE_CP
		@check cp1[:min] == 2
		@check !haskey(cp1,:max)
	end

	test("reps with non-literal min and max") do
		gn = CPRepsNonLiteralMinMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.SEQUENCE_CP
		@check !haskey(cp1,:min)
		@check !haskey(cp1,:max)
	end

	test("reps with no max") do
		gn = CPRepsNoMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.SEQUENCE_CP
		@check cp1[:min] == 2
		@check cp1[:max] == typemax(Int)
	end

	test("mult") do
		gn = CPMultGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.SEQUENCE_CP
		@check cp1[:min] == 0
		@check cp1[:max] == typemax(Int)
	end

	test("plus") do
		gn = CPPlusGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.SEQUENCE_CP
		@check cp1[:min] == 1
		@check cp1[:max] == typemax(Int)
	end
	
end

@generator CPRuleGen begin
	start() = x()
	x() = 'a'
	x() = 'b'
	x() = 'c'
end

describe("rule choice point info") do

	test("rule choice") do
		gn = CPRuleGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.RULE_CP
		@check cp1[:min] == 1
		@check cp1[:max] == 3
		@check cp1[:rulename] == :x
	end
	
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

describe("value choice point info") do

	test("choose Int with literal min and max") do
		gn = CPChooseIntLiteralMinMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Int
		@check cp1[:min] == 2
		@check cp1[:max] == 4
	end

	test("choose Int with non literal min") do
		gn = CPChooseIntNonLiteralMinGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Int
		@check !haskey(cp1,:min)
		@check cp1[:max] == 4
	end

	test("choose Int with non literal max") do
		gn = CPChooseIntNonLiteralMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Int
		@check cp1[:min] == 2
		@check !haskey(cp1,:max)
	end

	test("choose Int with non literal min and max") do
		gn = CPChooseIntNonLiteralMinMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Int
		@check !haskey(cp1,:min)
		@check !haskey(cp1,:max)
	end

	test("choose Int with no max") do
		gn = CPChooseIntNoMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Int
		@check cp1[:min] == 2
		@check cp1[:max] == typemax(Int)
	end

	test("choose Int with no min nor max") do
		gn = CPChooseIntNoMinMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Int
		@check cp1[:min] == typemin(Int)
		@check cp1[:max] == typemax(Int)
	end

	test("choose Float64 with literal min and max") do
		gn = CPChooseFloat64LiteralMinMaxGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Float64
		@check cp1[:min] == 2.1
		@check cp1[:max] == 4.2
	end

	test("choose Bool") do
		gn = CPChooseBoolGen()
		cpi = gn.choicepointinfo
		cpids = collect(keys(cpi))
		@check length(cpi) == 1
		cp1 = cpi[cpids[1]]
		@check cp1[:type] == GodelTest.VALUE_CP
		@check cp1[:datatype] == Bool
		@check cp1[:min] == false
		@check cp1[:max] == true
	end

end

@generator CPMultipleCPGen begin
	start() = mult(a)
	a() = choose(Int,2,4)
	a() = 'a'
end

describe("multiple choice points") do

	test("generator sequence, rule, and value choice points") do
		gn = CPMultipleCPGen()
		cpi = gn.choicepointinfo
		@check length(cpi) == 3
		cptypes = [cpdict[:type] for cpdict in values(cpi)]
		@check GodelTest.SEQUENCE_CP in cptypes
		@check GodelTest.RULE_CP in cptypes
		@check GodelTest.VALUE_CP in cptypes
	end
	
end

@generator CPBoolGen begin
	start() = choose(Bool)
end

@generator CPIntGen begin
	start() = choose(Int,5,9)
end

@generator CPMainGen(boolGen, intGen) begin
	start() = map(i->boolGen(), 1:intGen())
end

describe("choicepointinfo function") do

	test("returns info for the generator itself when no subgenerators") do
		gn = CPMultipleCPGen()
		cpi = gn.choicepointinfo
		@check choicepointinfo(gn) == cpi
	end

	test("returns info for the generator and the subgenerators when one or more subgenerators") do
		bgn = CPBoolGen()
		ign = CPIntGen()
		gn = CPMainGen(bgn,ign)
		bcpi = bgn.choicepointinfo
		icpi = ign.choicepointinfo
		cpi = gn.choicepointinfo
		@check choicepointinfo(gn) == merge(cpi,bcpi,icpi)
	end

end


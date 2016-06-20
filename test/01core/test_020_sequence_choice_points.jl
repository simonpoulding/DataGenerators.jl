# tests sequence choice points arising from reps, mult, and plus

using GodelTest

#
# reps(function_as_symbol, [min[, max]])
#

@generator SCRepsGen begin # prefix SC (for Sequence Choice points) to avoid type name clashes
start() = reps(a,2,4)
a() = gensym()
end

@testset "reps choice point" begin

gn = SCRepsGen()

@testset "returns array of different symbols with different lengths between minimum and maximum" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 2 <= length(td) <= 4
    @test all(map(x->typeof(x),td) .== Symbol)
    @test td[1] != td[2]
    @mcheck_values_include length(td) [2,3,4]
end
	
end


@generator SCRepsNoMaxGen begin
start() = reps(a,2)
a() = 'a'
end

@testset "reps choice point with no maximum" begin

gn = SCRepsNoMaxGen()

@testset "returns array of 'a's with different lengths of minimum or more" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 2 <= length(td)
    @test all(td .== 'a')
    @mcheck_values_include length(td) [2,3,4]
end
	
end


@generator SCRepsNoMinGen begin
start() = reps(a)
a() = 'a'
end

@testset "reps choice point with no minimum nor maximum" begin

gn = SCRepsNoMinGen()

@testset "returns array of 'a's with different lengths of 0 or more" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 0 <= length(td)
    @test all(td .== 'a')
    @mcheck_values_include length(td) [0,1,2]
end
	
end


@generator SCRepsNonLiteralMinMaxGen begin
start() = reps(a,2*2,5+1)
a() = 'a'	
end

@testset "reps choice point with non-literal minimum and maximum" begin

gn = SCRepsNonLiteralMinMaxGen()

@testset "returns array of 'a's with different lengths between minimum and maximum" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 4 <= length(td) <= 6
    @test all(td .== 'a')
    @mcheck_values_are length(td) [4,5,6]
end

end

@generator SCRepsRuleNonLiteralMinMaxGen begin
start() = reps(a,x(),y())
    a() = 'a'
x() = 4
y() = 6
end

@testset "reps choice point with non-literal minimum and maximum defined by rules" begin

gn = SCRepsRuleNonLiteralMinMaxGen()

@testset "returns array of 'a's with different lengths between minimum and maximum" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 4 <= length(td) <= 6
    @test all(td .== 'a')
    @mcheck_values_are length(td) [4,5,6]
end

end

@generator SCRepsShortFormParenGen begin
start() = reps(a(),2,4)
    a() = gensym()
end

@testset "reps choice point where function called uses short form with parentheses" begin

gn = SCRepsShortFormParenGen()

@testset "returns array of different symbols with different lengths between minimum and maximum" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 2 <= length(td) <= 4
    @test all(map(x->typeof(x),td) .== Symbol)
    @test td[1] != td[2]
    @mcheck_values_are length(td) [2,3,4]
end

end


@generator SCRepsRuleParamGen begin
start() = begin
    a = 12
    b = 60
    reps(add(a,b),2,4)
end
    add(x,y) = (gensym(),x+y)
end

@testset "reps choice point where function called with parameters" begin

gn = SCRepsRuleParamGen()

@testset "returns array of different tuples which use parameter values, with different lengths between minimum and maximum" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 2 <= length(td) <= 4
    td1 = map(x->x[1],td)
    td2 = map(x->x[2],td)
    @test all(map(x->typeof(x),td1) .== Symbol)
    @test td1[1] != td1[2]
    @test all(td2 .== 72)
    @mcheck_values_are length(td) [2,3,4]
end

end


@generator SCRepsNonRuleGen begin
start() = reps(gensym(),2,4)
end

@testset "reps choice point where function called is not a rule" begin

gn = SCRepsNonRuleGen()

@testset "returns array of different symbols with different lengths between minimum and maximum" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 2 <= length(td) <= 4
    @test all(map(x->typeof(x),td) .== Symbol)
    @test td[1] != td[2]
    @mcheck_values_are length(td) [2,3,4]
end

end


@generator SCSubGen() begin
start() = gensym()
end

@generator SCRepsSubGenGen(subgen) begin
start() = reps(subgen(),2,4)
end

@testset "reps choice point where function called is not a rule" begin

sg = SCSubGen()
gn = SCRepsSubGenGen(sg)

@testset "returns array of different symbols with different lengths between minimum and maximum" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 2 <= length(td) <= 4
    @test all(map(x->typeof(x),td) .== Symbol)
    @test td[1] != td[2]
    @mcheck_values_are length(td) [2,3,4]
end

end

#
# mult(function_as_symbol)
#

@generator SCMultGen begin
start() = mult(a)
a() = 'a'
end

@testset "mult choice point" begin

gn = SCMultGen()

@testset "returns array of 'a's with different lengths of 0 or more" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 0 <= length(td)
    @test all(td .== 'a')
    @mcheck_values_include length(td) [0,1,2]
end
	
end



#
# plus(function_as_symbol)
#


@generator SCPlusGen begin
start() = plus(a)
a() = 'a'
end

@testset "plus choice point" begin

gn = SCPlusGen()

@testset "returns array of 'a's with different lengths of 1 or more" for i in 1:NumReps 
    td = gen(gn)
    @test typeof(td) <: Array
    @test 1 <= length(td)
    @test all(td .== 'a')
    @mcheck_values_include length(td) [1,2,3]
end

end


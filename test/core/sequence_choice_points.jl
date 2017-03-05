# tests sequence choice points arising from reps, mult, and plus

#
# reps(function_as_symbol, [min[, max]])
#

# Can't define generators inside a @testset as it gives rise to error:
#    LoadError: error compiling anonymous: type definition not allowed inside a local scope
# but even though this scope is inside the local scope of a @testset block in runtests.jl, the 
# the fact the code is included in the local scope appears to avoid this issue

@generator SCRepsGen begin # prefix SC (for Sequence Choice points) to avoid type name clashes
start() = reps(a,2,4)
a() = gensym()
end

@generator SCRepsNoMaxGen begin
start() = reps(a,2)
a() = 'a'
end

@generator SCRepsNoMinGen begin
start() = reps(a)
a() = 'a'
end

@generator SCRepsNonLiteralMinMaxGen begin
start() = reps(a,2*2,5+1)
a() = 'a'	
end

@generator SCRepsRuleNonLiteralMinMaxGen begin
start() = reps(a,x(),y())
    a() = 'a'
x() = 4
y() = 6
end

@generator SCRepsShortFormParenGen begin
start() = reps(a(),2,4)
    a() = gensym()
end

@generator SCRepsRuleParamGen begin
start() = begin
    a = 12
    b = 60
    reps(add(a,b),2,4)
end
    add(x,y) = (gensym(),x+y)
end

@generator SCRepsNonRuleGen begin
start() = reps(gensym(),2,4)
end

@generator SCSubGen() begin
start() = gensym()
end

@generator SCRepsSubGenGen(subgen) begin
start() = reps(choose(subgen),2,4)
end

@generator SCMultGen begin
start() = mult(a)
a() = 'a'
end

@generator SCPlusGen begin
start() = plus(a)
a() = 'a'
end

@testset "sequence choice points" begin

	@testset MultiTestSet "reps choice point" begin

		gn = SCRepsGen()

		for i in 1:mtest_num_reps 
	    	td = choose(gn)
		    @test typeof(td) <: Array
		    @test 2 <= length(td) <= 4
		    @test all(map(x->typeof(x),td) .== Symbol)
		    @test td[1] != td[2]
		    @mtest_values_include length(td) [2,3,4]
		end
	
	end

	@testset MultiTestSet "reps choice point with no maximum" begin

		gn = SCRepsNoMaxGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 2 <= length(td)
		    @test all(td .== 'a')
		    @mtest_values_include length(td) [2,3,4]
		end
	
	end

	@testset MultiTestSet "reps choice point with no minimum nor maximum" begin

		gn = SCRepsNoMinGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 0 <= length(td)
		    @test all(td .== 'a')
		    @mtest_values_include length(td) [0,1,2]
		end
	
	end

	@testset MultiTestSet "reps choice point with non-literal minimum and maximum" begin

		gn = SCRepsNonLiteralMinMaxGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 4 <= length(td) <= 6
		    @test all(td .== 'a')
		    @mtest_values_are length(td) [4,5,6]
		end

	end

	@testset MultiTestSet "reps choice point with non-literal minimum and maximum defined by rules" begin

		gn = SCRepsRuleNonLiteralMinMaxGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 4 <= length(td) <= 6
		    @test all(td .== 'a')
		    @mtest_values_are length(td) [4,5,6]
		end

	end

	@testset MultiTestSet "reps choice point where function called uses short form with parentheses" begin

		gn = SCRepsShortFormParenGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 2 <= length(td) <= 4
		    @test all(map(x->typeof(x),td) .== Symbol)
		    @test td[1] != td[2]
		    @mtest_values_are length(td) [2,3,4]
		end

	end

	@testset MultiTestSet "reps choice point where function called with parameters" begin

		gn = SCRepsRuleParamGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 2 <= length(td) <= 4
		    td1 = map(x->x[1],td)
		    td2 = map(x->x[2],td)
		    @test all(map(x->typeof(x),td1) .== Symbol)
		    @test td1[1] != td1[2]
		    @test all(td2 .== 72)
		    @mtest_values_are length(td) [2,3,4]
		end

	end

	@testset MultiTestSet "reps choice point where function called is not a rule" begin

		gn = SCRepsNonRuleGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 2 <= length(td) <= 4
		    @test all(map(x->typeof(x),td) .== Symbol)
		    @test td[1] != td[2]
		    @mtest_values_are length(td) [2,3,4]
		end

	end

	@testset MultiTestSet "reps choice point where function called is not a rule" begin

		sg = SCSubGen()
		gn = SCRepsSubGenGen(sg)

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 2 <= length(td) <= 4
		    @test all(map(x->typeof(x),td) .== Symbol)
		    @test td[1] != td[2]
		    @mtest_values_are length(td) [2,3,4]
		end

	end

	#
	# mult(function_as_symbol)
	#

	@testset MultiTestSet "mult choice point" begin

		gn = SCMultGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 0 <= length(td)
		    @test all(td .== 'a')
		    @mtest_values_include length(td) [0,1,2]
		end
	
	end

	#
	# plus(function_as_symbol)
	#

	@testset MultiTestSet "plus choice point" begin

		gn = SCPlusGen()

		for i in 1:mtest_num_reps 
		    td = choose(gn)
		    @test typeof(td) <: Array
		    @test 1 <= length(td)
		    @test all(td .== 'a')
		    @mtest_values_include length(td) [1,2,3]
		end

	end

end
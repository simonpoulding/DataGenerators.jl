# tests sequence choice points arising from reps, mult, and plus

using GodelTest

#
# reps(function_as_symbol, [min[, max]])
#

@generator SCRepsGen begin # prefix SC (for Sequence Choice points) to avoid type name clashes
	start() = reps(a,2,4)
	a() = gensym()
end

describe("reps choice point") do

	gn = SCRepsGen()

	@repeat test("returns array of different symbols with different lengths between minimum and maximum") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 2 <= length(td) <= 4
		@check all(map(x->typeof(x),td) .== Symbol)
		@check td[1] != td[2]
		@mcheck_values_include length(td) [2,3,4]
	end
	
end


@generator SCRepsNoMaxGen begin
	start() = reps(a,2)
	a() = 'a'
end

describe("reps choice point with no maximum") do

	gn = SCRepsNoMaxGen()

	@repeat test("returns array of 'a's with different lengths of minimum or more") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 2 <= length(td)
		@check all(td .== 'a')
		@mcheck_values_include length(td) [2,3,4]
	end
	
end


@generator SCRepsNoMinGen begin
	start() = reps(a)
	a() = 'a'
end

describe("reps choice point with no minimum nor maximum") do

	gn = SCRepsNoMinGen()

	@repeat test("returns array of 'a's with different lengths of 0 or more") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 0 <= length(td)
		@check all(td .== 'a')
		@mcheck_values_include length(td) [0,1,2]
	end
	
end


@generator SCRepsNonLiteralMinMaxGen begin
	start() = reps(a,2*2,5+1)
	a() = 'a'	
end

describe("reps choice point with non-literal minimum and maximum") do

	gn = SCRepsNonLiteralMinMaxGen()

	@repeat test("returns array of 'a's with different lengths between minimum and maximum") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 4 <= length(td) <= 6
		@check all(td .== 'a')
		@mcheck_values_include length(td) [4,5,6]
	end

end

@generator SCRepsRuleNonLiteralMinMaxGen begin
	start() = reps(a,x(),y())
  a() = 'a'
	x() = 4
	y() = 6
end

describe("reps choice point with non-literal minimum and maximum defined by rules") do

	gn = SCRepsRuleNonLiteralMinMaxGen()

	@repeat test("returns array of 'a's with different lengths between minimum and maximum") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 4 <= length(td) <= 6
		@check all(td .== 'a')
		@mcheck_values_include length(td) [4,5,6]
	end

end

@generator SCRepsShortFormParenGen begin
	start() = reps(a(),2,4)
  a() = gensym()
end

describe("reps choice point where function called uses short form with parentheses") do

	gn = SCRepsShortFormParenGen()

	@repeat test("returns array of different symbols with different lengths between minimum and maximum") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 2 <= length(td) <= 4
		@check all(map(x->typeof(x),td) .== Symbol)
		@check td[1] != td[2]
		@mcheck_values_include length(td) [2,3,4]
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

describe("reps choice point where function called with parameters") do

	gn = SCRepsRuleParamGen()

	@repeat test("returns array of different tuples which use parameter values, with different lengths between minimum and maximum") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 2 <= length(td) <= 4
		td1 = map(x->x[1],td)
		td2 = map(x->x[2],td)
		@check all(map(x->typeof(x),td1) .== Symbol)
		@check td1[1] != td1[2]
		@check all(td2 .== 72)
		@mcheck_values_include length(td) [2,3,4]
	end

end


@generator SCRepsNonRuleGen begin
	start() = reps(gensym(),2,4)
end

describe("reps choice point where function called is not a rule") do

	gn = SCRepsNonRuleGen()

	@repeat test("returns array of different symbols with different lengths between minimum and maximum") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 2 <= length(td) <= 4
		@check all(map(x->typeof(x),td) .== Symbol)
		@check td[1] != td[2]
		@mcheck_values_include length(td) [2,3,4]
	end

end


@generator SCSubGen() begin
	start() = gensym()
end

@generator SCRepsSubGenGen(subgen) begin
	start() = reps(subgen(),2,4)
end

describe("reps choice point where function called is not a rule") do

	sg = SCSubGen()
	gn = SCRepsSubGenGen(sg)

	@repeat test("returns array of different symbols with different lengths between minimum and maximum") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 2 <= length(td) <= 4
		@check all(map(x->typeof(x),td) .== Symbol)
		@check td[1] != td[2]
		@mcheck_values_include length(td) [2,3,4]
	end

end

#
# mult(function_as_symbol)
#

@generator SCMultGen begin
	start() = mult(a)
	a() = 'a'
end

describe("mult choice point") do

	gn = SCMultGen()

	@repeat test("returns array of 'a's with different lengths of 0 or more") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 0 <= length(td)
		@check all(td .== 'a')
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

describe("plus choice point") do

	gn = SCPlusGen()

	@repeat test("returns array of 'a's with different lengths of 1 or more") do
		td = gen(gn)
		@check typeof(td) <: Array
		@check 1 <= length(td)
		@check all(td .== 'a')
		@mcheck_values_include length(td) [1,2,3]
	end

end


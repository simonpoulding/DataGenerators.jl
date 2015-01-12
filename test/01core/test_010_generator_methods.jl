# tests handling of generator methods by macro

using GodelTest

#
# short form: a() = ...
# long form: function a() ... end
# short form without paranthesis: a = ...
#

# to ensure the method a() really is being interpreted as a function, rather than a variable,
# it is called twice: each call will return a different symbols


@generator GMShortGen begin # prefix GM (for Generator Methods) to avoid type name clashes
	start() = (a(), a())
	a() = gensym()
end

describe("method defined using function short form") do

	gn = GMShortGen()
	
	test("emits pair of different symbols") do
		td = gen(gn)
		@check typeof(td) == (Symbol,Symbol)
		@check td[1] != td[2]
	end
	
end


@generator GMShortBlockGen begin
	start() = (a(), a())
	a() = begin
		gensym()
	end
end

describe("method defined using function short form including being block") do

	gn = GMShortBlockGen()
	
	test("emits pair of different symbols") do
		td = gen(gn)
		@check typeof(td) == (Symbol,Symbol)
		@check td[1] != td[2]
	end
	
end


@generator GMLongGen begin
	start() = (a(), a())
	function a()
		gensym()
	end
end

describe("method defined using function long form") do

	gn = GMLongGen()
	
	test("emits pair of different symbols") do
		td = gen(gn)
		@check typeof(td) == (Symbol,Symbol)
		@check td[1] != td[2]
	end
	
end


@generator GMShortNoParenGen begin
	start() = (a(), a())
	a = gensym()
end

describe("method defined using function short form without parentheses") do

	gn = GMShortNoParenGen()
	
	test("emits pair of different symbols") do
		td = gen(gn)
		@check typeof(td) == (Symbol,Symbol)
		@check td[1] != td[2]
	end
	
end


@generator GMCallNoParenGen begin
	start() = (a, b, c)
	a = 'a'
	b() = 'b'
	function c()
		'c'
	end
end

describe("method called using short no paren form") do

	gn = GMCallNoParenGen()
	
	test("all three rules are called") do
		td = gen(gn)
		@check td == ('a','b','c')
	end
	
end

@generator GMLiteralParamGen begin
	start() = (add(4,2), sub(4,2))
	add(x,y) = x+y
	function sub(x,y)
		x-y
	end
end

describe("method called with literal parameters") do

	gn = GMLiteralParamGen()
	
	test("parameters are passed correctly") do
		td = gen(gn)
		@check td == (6,2)
	end
	
end

@generator GMNonLiteralParamGen begin
	start() = begin
		a = 7
		b = 3
		(add(a,b), sub(a,b))
	end
	add(x,y) = x+y
	function sub(x,y)
		x-y
	end
end

describe("method called with non literal parameters") do

	gn = GMNonLiteralParamGen()
	
	test("parameters are passed correctly") do
		td = gen(gn)
		@check td == (10,4)
	end
	
end

@generator GMBlockGen begin
	begin
		start() = a()
	end
	begin
		a() = b()
		begin
			b() = 42
		end
	end
end

describe("methods defined inside a block") do

	gn = GMBlockGen()
	
	test("rules identified inside a block") do
		td = gen(gn)
		@check td == 42
	end
	
end
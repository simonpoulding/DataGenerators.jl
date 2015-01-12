# tests String value choice points, i.e. using choose(StringDataType, regex) construct

using GodelTest


@generator SCWildcardGen begin # prefix SC (for String value Choice points) to avoid type name clashes
	start() = choose(ASCIIString, ".")
end

describe("choose(ASCIIString) using regex containing wilcard") do

	gn = SCWildcardGen()

  @repeat test("emits different ASCII strings that match regex") do
		td = gen(gn)
		@check typeof(td) == ASCIIString
		@check ismatch(r"^.$", td)
		@mcheck_values_vary td
	end
	
end


@generator SCQuantifiersGen begin
	start() = choose(ASCIIString, "a?b+c*d{4}e{5,6}f{7,}g{8,8}")
end

describe("choose(ASCIIString) using regex containing quantifiers") do

	gn = SCQuantifiersGen()

  @repeat test("emits different ASCII strings that match regex") do
		td = gen(gn)
		@check typeof(td) == ASCIIString
		@check ismatch(r"^a?b+c*d{4}e{5,6}f{7,}g{8,8}$", td)
		@mcheck_values_include count(x->x=='a',td) [0,1]
		@mcheck_values_include count(x->x=='b',td) [1,2,3]
		@mcheck_values_include count(x->x=='c',td) [0,1,2]
		@mcheck_values_include count(x->x=='d',td) [4,]
		@mcheck_values_include count(x->x=='e',td) [5,6]
		@mcheck_values_include count(x->x=='f',td) [7,8,9]
		@mcheck_values_are count(x->x=='g',td) [8]
	end
	
end


@generator SCAlternationGen begin
	start() = choose(ASCIIString, "foo|bar|baz")
end

describe("choose(ASCIIString) using regex containing alternation") do

	gn = SCAlternationGen()

  @repeat test("emits different ASCII strings that match regex") do
		td = gen(gn)
		@check typeof(td) == ASCIIString
		@check ismatch(r"^foo|bar|baz$", td)
		@mcheck_values_are td ["foo","bar","baz"]
	end
	
end


@generator SCBracketsGen begin
	start() = choose(ASCIIString, "a[uvw][x-z0-3]b")
end

describe("choose(ASCIIString) using regex containing bracket") do

	gn = SCBracketsGen()

  @repeat test("emits different ASCII strings that match regex") do
		td = gen(gn)
		@check typeof(td) == ASCIIString
		@check ismatch(r"^a[uvw][x-z0-3]b$", td)
		@mcheck_values_are td[2] ['u','v','w']
		@mcheck_values_are td[3] ['x','y','z','0','1','2','3']
	end
	
end


@generator SCParenthesesGen begin
	start() = choose(ASCIIString, "a(bc|de)")
end

describe("choose(ASCIIString) using regex containing parentheses") do

	gn = SCParenthesesGen()

  @repeat test("emits different ASCII strings that match regex") do
		td = gen(gn)
		@check typeof(td) == ASCIIString
		@check ismatch(r"^a(bc+|de+)$", td)
		@mcheck_values_are td[2] ['b','d']
		@mcheck_values_are td[3] ['c','e']
	end
	
end


@generator SCClassesGen begin
	start() = choose(ASCIIString, "\\s\\S\\d\\D\\w\\W")
end

describe("choose(ASCIIString) using regex containing classes") do

	gn = SCClassesGen()

  @repeat test("emits different ASCII strings that match regex") do
		td = gen(gn)
		@check typeof(td) == ASCIIString
		@check ismatch(r"^\s\S\d\D\w\W$", td)
		@mcheck_values_vary td
	end
	
end

@generator SCEscapesGen begin
	start() = choose(ASCIIString, "\\.\\[\\]\\|\\?\\+\\*\\\\")
end

describe("choose(ASCIIString) using regex that escapes metacharacters") do

	gn = SCEscapesGen()

  @repeat test("emits different ASCII strings that match regex") do
		td = gen(gn)
		@check typeof(td) == ASCIIString
		@check ismatch(r"^\.\[\]\|\?\+\*\\$", td)
	end
	
end

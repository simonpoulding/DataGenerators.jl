# tests String value choice points, i.e. using choose(StringDataType, regex) construct

@generator SCWildcardGen begin # prefix SC (for String value Choice points) to avoid type name clashes
    start() = choose(ASCIIString, ".")
end

@testset "choose(ASCIIString) using regex containing wilcard" begin

gn = SCWildcardGen()

@testset repeats=NumReps "emits different ASCII strings that match regex" begin
    td = choose(gn)
    @test typeof(td) == ASCIIString
    @test ismatch(r"^.$", td)
    @mcheck_values_vary td
end
	
end


@generator SCQuantifiersGen begin
    start() = choose(ASCIIString, "a?b+c*d{4}e{5,6}f{7,}g{8,8}")
end

@testset "choose(ASCIIString) using regex containing quantifiers" begin

gn = SCQuantifiersGen()

@testset repeats=NumReps "emits different ASCII strings that match regex" begin
    td = choose(gn)
    @test typeof(td) == ASCIIString
    @test ismatch(r"^a?b+c*d{4}e{5,6}f{7,}g{8,8}$", td)
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

@testset "choose(ASCIIString) using regex containing alternation" begin

gn = SCAlternationGen()

@testset repeats=NumReps "emits different ASCII strings that match regex" begin
    td = choose(gn)
    @test typeof(td) == ASCIIString
    @test ismatch(r"^foo|bar|baz$", td)
    @mcheck_values_are td ["foo","bar","baz"]
end
	
end


@generator SCBracketsGen begin
    start() = choose(ASCIIString, "a[uvw][x-z0-3]b")
end

@testset "choose(ASCIIString) using regex containing bracket" begin

gn = SCBracketsGen()

@testset repeats=NumReps "emits different ASCII strings that match regex" begin
    td = choose(gn)
    @test typeof(td) == ASCIIString
    @test ismatch(r"^a[uvw][x-z0-3]b$", td)
    @mcheck_values_are td[2] ['u','v','w']
    @mcheck_values_are td[3] ['x','y','z','0','1','2','3']
end
	
end


@generator SCParenthesesGen begin
    start() = choose(ASCIIString, "a(bc|de)")
end

@testset "choose(ASCIIString) using regex containing parentheses" begin

gn = SCParenthesesGen()

@testset repeats=NumReps "emits different ASCII strings that match regex" begin
    td = choose(gn)
    @test typeof(td) == ASCIIString
    @test ismatch(r"^a(bc+|de+)$", td)
    @mcheck_values_are td[2] ['b','d']
    @mcheck_values_are td[3] ['c','e']
end
	
end


@generator SCClassesGen begin
    start() = choose(ASCIIString, "\\s\\S\\d\\D\\w\\W")
end

@testset "choose(ASCIIString) using regex containing classes" begin

gn = SCClassesGen()

@testset repeats=NumReps "emits different ASCII strings that match regex" begin
    td = choose(gn)
    @test typeof(td) == ASCIIString
    @test ismatch(r"^\s\S\d\D\w\W$", td)
    @mcheck_values_vary td
end
	
end

@generator SCEscapesGen begin
    start() = choose(ASCIIString, "\\.\\[\\]\\|\\?\\+\\*\\\\")
end

@testset "choose(ASCIIString) using regex that escapes metacharacters" begin

gn = SCEscapesGen()

@testset repeats=NumReps "emits different ASCII strings that match regex" begin
    td = choose(gn)
    @test typeof(td) == ASCIIString
    @test ismatch(r"^\.\[\]\|\?\+\*\\$", td)
end
	
end

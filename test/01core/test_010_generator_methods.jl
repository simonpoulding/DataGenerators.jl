# tests handling of generator methods by macro

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

@testset "method defined using function short form" begin

gn = GMShortGen()
	
@testset "emits pair of different symbols" begin
    td = gen(gn)
    @test typeof(td) == Tuple{Symbol,Symbol}
    @test td[1] != td[2]
end
	
end


@generator GMShortBlockGen begin
start() = (a(), a())
a() = begin
    gensym()
end
end

@testset "method defined using function short form including being block" begin

gn = GMShortBlockGen()
	
@testset "emits pair of different symbols" begin
    td = gen(gn)
    @test typeof(td) == Tuple{Symbol,Symbol}
    @test td[1] != td[2]
end
	
end


@generator GMLongGen begin
start() = (a(), a())
function a()
    gensym()
end
end

@testset "method defined using function long form" begin

gn = GMLongGen()
	
@testset "emits pair of different symbols" begin
    td = gen(gn)
    @test typeof(td) == Tuple{Symbol,Symbol}
    @test td[1] != td[2]
end
	
end


@generator GMShortNoParenGen begin
start() = (a(), a())
a = gensym()
end

@testset "method defined using function short form without parentheses" begin

gn = GMShortNoParenGen()
	
@testset "emits pair of different symbols" begin
    td = gen(gn)
    @test typeof(td) == Tuple{Symbol,Symbol}
    @test td[1] != td[2]
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

@testset "method called using short no paren form" begin

gn = GMCallNoParenGen()
	
@testset "all three rules are called" begin
    td = gen(gn)
    @test td == ('a','b','c')
end
	
end

@generator GMLiteralParamGen begin
start() = (add(4,2), sub(4,2))
add(x,y) = x+y
function sub(x,y)
    x-y
end
end

@testset "method called with literal parameters" begin

gn = GMLiteralParamGen()
	
@testset "parameters are passed correctly" begin
    td = gen(gn)
    @test td == (6,2)
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

@testset "method called with non literal parameters" begin

gn = GMNonLiteralParamGen()
	
@testset "parameters are passed correctly" begin
    td = gen(gn)
    @test td == (10,4)
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

@testset "methods defined inside a block" begin

gn = GMBlockGen()
	
@testset "rules identified inside a block" begin
    td = gen(gn)
    @test td == 42
end
	
end
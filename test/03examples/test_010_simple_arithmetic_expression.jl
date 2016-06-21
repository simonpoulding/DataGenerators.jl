# simple arithmetic expression generator

# note: no recursion so as to avoid issue of infinite strings
@generator EXSimpleExprGen begin 
    start() = expression()
    expression() = operand() * " " * operator() * " " * operand()
    operand() = (choose(Bool) ? "-" : "") * join(plus(digit))
    digit() = string(choose(Int,0,9))
    operator() = "+"
    operator() = "-"
    operator() = "/"
    operator() = "*"
end

@testset "simple arithmetic expression generator" begin

gn = EXSimpleExprGen()

@testset repeats=NumReps "emits a valid simple expression as a string" begin
    td = gen(gn)
    @test typeof(td) <: AbstractString
    @test ismatch(r"^-?[0-9]+ [+\-/*] -?[0-9]+$", td)
    @mcheck_values_vary td
end
	
end

module TestModule

using GodelTest

export samp

function addbang(x)
	x * "!"
end

c = :+

# ex = macroexpand( :(
@generator SimpleExprGen begin 
  start() = expression()
  expression() = operand() * " " * operator() * " " * operand()
  operand() = (choose(Bool) ? "-" : string(c)) * addbang(join(plus(digit)))
  digit() = string(choose(Int,0,9))
  operator() = "+"
  operator() = "-"
  operator() = "/"
  operator() = "*"
end
# ) )
# println(ex)

function samp()
	gn = SimpleExprGen()
	gen(gn)
end

end

using TestModule

println("Emitted: $(samp())")

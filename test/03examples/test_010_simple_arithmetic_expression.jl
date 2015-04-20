# simple arithmetic expression generator

using GodelTest

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

describe("simple arithmetic expression generator") do

	gn = EXSimpleExprGen()

	@repeat test("emits a valid simple expression as a string") do
		td = gen(gn)
		@check typeof(td) <: String
		@check ismatch(r"^-?[0-9]+ [+\-/*] -?[0-9]+$", td)
		@mcheck_values_vary td
	end
	
end

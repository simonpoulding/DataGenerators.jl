require("../src/GodelTest.jl")
using GodelTest
using BlackBoxOptim

# generator for simple arithmetic expressions
@generator SimpleExprGen begin
  start = expression
  expression = operand * " " * operator * " " * operand
  operand = (choose(Bool) ? "-" : "") * join(plus(digit))
  digit = string(choose(Int,0,9))
  operator = "+"
  operator = "-"
  operator = "/"
  operator = "*"
end

# create a generator instance
gn = SimpleExprGen()

# create a choice model using the sampler choice model
cm = SamplerChoiceModel(gn)

# define a fitness function (here as a closure)
# argument is a vector of model parameters
function fitnessfn(modelparams)
	# sets parameters of choice model
	setparams(cm, vec(modelparams))  
	# get a sample of data items from the generator using this choice model
	exprs = [gen(gn, choicemodel=cm) for i in 1:100]
	# calculate the fitness - here the mean distance of the length expression from 16
	mean(map(expr->abs(16-length(expr)), exprs))
end

# optimise the choice model params
# paramranges returns a vector of tuples that specify the valid ranges of the model parameters
# bboptimize is from the BlackBoxOptim package
optimresult = bboptimize(fitnessfn; search_range = paramranges(cm))
bestmodelparams = optimresult[1]

# apply the best parameters found
setparams(cm, vec(bestmodelparams))

# generate data using the optimised model
[gen(gn, choicemodel=cm) for i in 1:10]


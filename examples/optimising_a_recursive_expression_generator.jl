require("../src/DataGenerators.jl")
using DataGenerators
using BlackBoxOptim

# recursive generator for arithmetic expressions
@generator RecursiveExprGen begin
  start = expression
  expression = operand * " " * operator * " " * operand
  operand = number
	operand = "(" * expression * ")"
	number = (choose(Bool) ? "-" : "") * join(plus(digit))
  digit = string(choose(Int,0,9))
  operator = "+"
  operator = "-"
  operator = "/"
  operator = "*"
end

# create a generator instance
gn = RecursiveExprGen()

# create a choice model using the sampler choice model
cm = SamplerChoiceModel(gn)

# Number of expressions sampled when comparing different choice models
NumSamples = 10000

# Limit on the number of choices made per generation
MaxChoices = 200

# Generate examples from unoptimized model
unoptimized_examples = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumSamples]

# Number of generated data items per fitness calculation
NumDataPerFitnessCalc = 12

# Target length of expressions
GoalLength = 40

# handles length when string is nothing
robustlength(x) = x==nothing ? 1000 : length(x)

# define a fitness function (here as a closure)
# argument is a vector of model parameters
function fitnessfn(modelparams)
	# sets parameters of choice model
	setparams(cm, vec(modelparams))  
	# get a sample of data items from the generator using this choice model
	exprs = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumDataPerFitnessCalc]
	# gencatch returns nothing if generator terminated owing the maxchoices being exceeded
	mean(map(expr->abs(GoalLength-robustlength(expr)), exprs))
	# nothing indicates generator had a exception, so penalise with an arbitrary value
end

# optimise the choice model params with BlackBoxOptim
# paramranges returns a vector of tuples that specify the valid ranges of the model parameters
# bboptimize is from the BlackBoxOptim package
optimresult = bboptimize(fitnessfn; search_range = paramranges(cm), max_time = 10.0)
bestmodelparams = optimresult[1]

# apply the best parameters found
setparams(cm, vec(bestmodelparams))

# generate data using the optimised model
optimized_examples = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumSamples]

# Print examples so they can be compared
report(examples, desc) = begin
  mean_length = mean(map(robustlength, examples))
  println("\n", desc, " examples (avg. length = $mean_length):\n  ", 
    examples[1:min(10, length(examples))])
end
report(unoptimized_examples, "Unoptimized")
report(optimized_examples, "Optimized (with BlackBoxOptim)")

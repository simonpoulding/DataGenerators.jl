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

# Number of expressions sampled when comparing different choice models
NumSamples = 10000

# Generate examples from unoptimized model
unoptimized_examples = [gen(gn, choicemodel=cm) for i in 1:NumSamples]

# Number of generated data items per fitness calculation
NumDataPerFitnessCalc = 12

# Target length of expressions
TargetLength = 16

# define a fitness function (here as a closure)
# argument is a vector of model parameters
function fitnessfn(modelparams)
	# sets parameters of choice model
	setparams(cm, vec(modelparams))  
	# get a sample of data items from the generator using this choice model
	exprlengths = map(1:NumDataPerFitnessCalc) do i
		exprlength = 0
		try
			exprlength = length(gen(gn, choicemodel=cm, maxchoices=100))
			# maxchoices is the maximum number of choices made during generation; defaults to 10000
			# a GenerationTerminatedException is raised if this limit is exceeded, and so prevents extremely large objects
			# (e.g. from highly recursive generators) consuming all available resources
		catch e
			if isa(e, GenerationTerminatedException)
				exprlength = 101 # set an arbitrary length that will penalise the fitness function
			else
				throw(e) # rethrow other types of error
			end
		end
		abs(TargetLength - exprlength)
	end
	mean(exprlengths)
end

# optimise the choice model params with BlackBoxOptim
# paramranges returns a vector of tuples that specify the valid ranges of the model parameters
# bboptimize is from the BlackBoxOptim package
optimresult = bboptimize(fitnessfn; search_range = paramranges(cm), max_time = 10.0)
bestmodelparams = optimresult[1]

# apply the best parameters found
setparams(cm, vec(bestmodelparams))

# generate data using the optimised model
optimized_examples = [gen(gn, choicemodel=cm) for i in 1:NumSamples]

# Print examples so they can be compared
report(examples, desc) = begin
  mean_length = mean(map(length, examples))
  println("\n", desc, " examples (avg. length = $mean_length):\n  ", 
    examples[1:min(10, length(examples))])
end
report(unoptimized_examples, "Unoptimized")
report(optimized_examples, "Optimized (with BlackBoxOptim)")

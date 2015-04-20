require("../src/GodelTest.jl")
using GodelTest
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

# Create alternative SamplerChoiceModel that uses a
# mixture of a gaussian and a geometric for the sequence choice points.
# This is a kludge for now...
# function SamplerChoiceModelRF(g::GodelTest.Generator, subgencms=[])
#   samplers = (Uint=>GodelTest.Sampler)[]
#   for (cpid, info) in choicepointinfo(g) # gets info from sub-generators also
#     cptype = info[:type]
#     if cptype == GodelTest.RULE_CP
#       sampler = GodelTest.CategoricalSampler(info[:max])
#     elseif cptype == GodelTest.SEQUENCE_CP
#       sampler = GodelTest.MixtureSampler([GodelTest.GeometricSampler(),
#         # Actually we need to ensure positive results to get good optimization. Investigate.
#         GodelTest.EnsurePositiveSampler(GodelTest.GaussianSampler(0.0, 100.0, 10.0, true))])
#         #GodelTest.GaussianSampler(0.0, 1000.0, 10.0, true)])
#     elseif cptype == GodelTest.VALUE_CP
#       datatype = info[:datatype]
#       if datatype <: Bool
#         sampler = GodelTest.BernoulliSampler()
#       elseif datatype <: Integer # order of if clauses matters here since Bool <: Integer
#         sampler = GodelTest.DiscreteUniformSampler()
#       else # floating point, but may also be a rational type
#         sampler = GodelTest.UniformSampler()
#       end
#     else
#       error("unrecognised choice point type when creating sampler choice model")
#     end
#     samplers[cpid] = sampler
#   end
#   for subgencm in subgencms
#     merge!(samplers, subgencm.samplers)
#   end
#   GodelTest.SamplerChoiceModel(samplers)
# end

# SMP - converted the above to use these new features now avaiable:
# (1) choicepointmapping parameter to SamplerChoiceModel to modify samplers used
# (2) new MixtureSampler
# (3) new NormalSampler
# (note: does not currently constrain the parameter ranges of the NormalSampler)
# BUT... currently large param ranges give rise to an error from BlackBoxOptim:
#    ArgumentError("Invalid search range specification.") 
function custommapping(info::Dict)
	cptype = info[:type]
	if cptype == GodelTest.RULE_CP
	  sampler = GodelTest.CategoricalSampler(info[:max])
	elseif cptype == GodelTest.SEQUENCE_CP
	  minreps = haskey(info,:min) ? info[:min] : 0
	  sampler = GodelTest.TransformSampler(
					GodelTest.MixtureSampler(GodelTest.GeometricSampler(), GodelTest.NormalSampler([50.0, 5.0])),
					x->floor(abs(x))+minreps,
					x->x-minreps) 
	elseif cptype == GodelTest.VALUE_CP
		datatype = info[:datatype]
		if datatype <: Bool
			sampler = GodelTest.BernoulliSampler()
		elseif datatype <: Integer # order of if clauses matters here since Bool <: Integer
			sampler = GodelTest.AdjustParametersToSupportSampler(GodelTest.DiscreteUniformSampler())
		else
			sampler = GodelTest.AdjustParametersToSupportSampler(GodelTest.UniformSampler())
		end
	else
	  error("unrecognised choice point type when creating custom sampler mapping")
	end
end

# create a choice model using the sampler choice model with the customised mapping that uses a mixture model
cm = SamplerChoiceModel(gn, choicepointmapping=custommapping)

# Number of expressions sampled when comparing different choice models
NumSamples = 10000

# Limit on the number of choices made per generation
MaxChoices = 200

# Generate examples from unoptimized model
unoptimized_examples = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumSamples]

# Number of generated data items per fitness calculation
NumDataPerFitnessCalc = 15

# Target length of expressions
GoalLength = 20

# handles length when string is nothing
robustlength(x) = x==nothing ? 1000 : length(x)

# Possibly we can get away from long/unrealistic numbers in output by giving extra
# fitness if there are more operators in the output?
count_operators(s) = s==nothing ? 0.5 : count((c) -> in(c, ['+', '-', '*', '/']), split(s, ""))

# define a fitness function (here as a closure)
# argument is a vector of model parameters
function fitnessfn(modelparams)
	# sets parameters of choice model
	setparams(cm, vec(modelparams))  
	# get a sample of data items from the generator using this choice model
	exprs = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumDataPerFitnessCalc]
	# gencatch returns nothing if generator terminated owing the maxchoices being exceeded
	mean(map(e -> abs(GoalLength-robustlength(e)), exprs))
	# nothing indicates generator had a exception, so penalise with an arbitrary value
end

# optimise the choice model params with BlackBoxOptim
# paramranges returns a vector of tuples that specify the valid ranges of the model parameters
# bboptimize is from the BlackBoxOptim package
optimresult = bboptimize(fitnessfn; search_range = paramranges(cm), max_time = 5.0)
bestmodelparams = optimresult[1]

# apply the best parameters found
setparams(cm, vec(bestmodelparams))
@show cm

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

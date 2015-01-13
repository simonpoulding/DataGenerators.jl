require("../src/GodelTest.jl")
using GodelTest
using NLopt

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

# Goal length of generated expressions
GoalLength = 16

# Max time for optimization, per algorithm
MaxTimeForOpt = 10.0

# define a fitness function (here as a closure)
# argument is a vector of model parameters
function fitnessfn(modelparams)
	# sets parameters of choice model
	setparams(cm, vec(modelparams))  
	# get a sample of data items from the generator using this choice model
	exprs = [gen(gn, choicemodel=cm) for i in 1:NumDataPerFitnessCalc]
	# calculate the fitness - here the mean distance of the length expression from 16
	mean(map(expr->abs(GoalLength-length(expr)), exprs))
end

# optimise the choice model params with different NLopt algorithms
NLoptAlgsLocal = [:LN_COBYLA, :LN_BOBYQA, :LN_NEWUOA, :LN_PRAXIS, :LN_NELDERMEAD, :LN_SBPLX]
NLoptAlgsGlobal = [:GN_DIRECT, :GN_DIRECT_L, :GN_CRS2_LM, :GN_IS_RES, :GN_ESCH]
NLoptAlgs = [NLoptAlgsLocal, NLoptAlgsGlobal]

# paramranges returns a vector of tuples that specify the valid ranges of the model parameters
search_range = paramranges(cm)
numparams = length(search_range)

run_nlopt(alg) = begin
  opt = Opt(:LN_NELDERMEAD, length(search_range))
  lower_bounds!(opt, map(first, search_range))
  upper_bounds!(opt, map((t) -> t[2], search_range))
  xtol_abs!(opt, 1e-8 * ones(numparams))
  maxtime!(opt, MaxTimeForOpt)
  min_objective!(opt, (x::Vector, grad::Vector) -> fitnessfn(x))
  rand_from_range(t) = t[1] + (t[2] - t[1]) * rand()
  rand_starting_point = map(rand_from_range, search_range)
  println("Running NLopt with algorithm $alg")
  optimresult = optimize(opt, rand_starting_point)
  bestmodelparams = optimresult[2]
end

calc_mean_length(examples) = mean(map(length, examples))

results = Any[]
for alg in NLoptAlgs
  bestmodelparams = run_nlopt(alg)

  # apply the best parameters found
  setparams(cm, vec(bestmodelparams))

  # generate data using the optimised model
  optimized_examples = [gen(gn, choicemodel=cm) for i in 1:NumSamples]

  push!(results, (alg, calc_mean_length(optimized_examples), optimized_examples))
end

# We want to look at both avg length, std dev and percent "spot on".
percent_true(pred, values) = 100.0 * count(pred, values) / length(values)
function eval_fitness_of_example_items(items, goal)
  lens = zeros(length(items))
  for i in 1:length(items)
    lens[i] = length(items[i])
  end
  return (mean(lens), std(lens), percent_true((l) -> l == goal, lens),
    percent_true((l) -> (goal-1) <= l <= (goal+1), lens))
end

# Print examples so they can be compared
report(examples, desc) = begin
  ml, sdl, phits, pnearhits = eval_fitness_of_example_items(examples, GoalLength)
  println("\n", desc, " examples (avg. length = $(round(ml, 2)), stdev = $(round(sdl,2))",
    ", hits = $(round(phits, 2))%, nearhits = $(round(pnearhits, 2))%):\n  ", 
    examples[1:min(5, length(examples))])
end

# Print unoptimized and then with best avg reported last
println("With $MaxTimeForOpt seconds of optimization:\n")
results = sort(results, by = (t) -> abs(GoalLength - t[2]), rev=true)
for (alg, meanlen, examples) in results
  report(examples, "$alg NLopt optimized")
end
report(unoptimized_examples, "Unoptimized")

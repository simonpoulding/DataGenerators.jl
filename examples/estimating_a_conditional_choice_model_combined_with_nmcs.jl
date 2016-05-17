# An exmple of using an EDA-like iterative approach to optimising a conditional model, combined with "local" NMCS
# when retrieving good sample with which to estimate the model
#


using GodelTest

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

# Number of expressions sampled when comparing different choice models
NumSamples = 100

# Limit on the number of choices made per generation
MaxChoices = 200

# Target length of expressions
GoalLength = 40

# handles length when string is nothing
robustlength(x) = x==nothing ? 1000 : length(x)

# define a fitness function for NMCS
fitnessfn(x) = abs(GoalLength-robustlength(x))

# sampler choice model
scm = SamplerChoiceModel(gn)

# now make all the choice points conditional by wrapping the choice point in a conditional sampler (could also be achieved
# by specifying a custom mapping function to the choice model constructor)
# note that we don't specify a parent here, so this means at this point the conditional sampler simply
# applies the underlying sampler, i.e. as if there were no conditionality
for cpid in keys(scm.samplers)
	if numparams(scm.samplers[cpid]) > 0 # no point making samplers without parameters conditional
		scm.samplers[cpid] = GodelTest.ConditionalSampler(scm.samplers[cpid])
	end
end

function output_model_info(cm)

	println("----------")
	
	# pretty print the current choice model
	println("Model structure:")
	println(cm)
	println()

	# estimate average current length
	examples = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:100]
	meanlength = mean(map(robustlength, examples))
	println("Average length of expression output (not using NMCS): $(meanlength)")

	# output some examples
	println("Examples: $(examples[1:10])")

	println("----------")

end


for edageneration in 1:5

	println()
	println("Properties of sampler choice model prior to EDA generation $(edageneration): ")
	output_model_info(scm)

	# get some traces using NMCS
	# in effect, NMCS is applying the evolutionary "pressure" here by finding good solutions
	# we then use these good traces to restimate the model
	selectedtraces = Vector()
	println("Sampling from current sampler choice model: ")
	while length(selectedtraces) <= 20
		try
			result, state = generate(gn, choicemodel=NMCSChoiceModel(scm, fitnessfn, 10), maxchoices=MaxChoices)
			println("Length: $(robustlength(result)) for: $(result)")
			push!(selectedtraces, state.cmtrace)
		catch e
		  	if isa(e,GenerationTerminatedException)
				println("(max choices reached)")
				continue # skip the remainder of this loop iteration
			else
				throw(e)
			end
		end
	end
	println()

	# We use the selected traces to estimate the dependencies in the conditional model, and the conditional distributions
	# at each choice point.
	# For each choice point in the model, this method will identify any "parent" choice points where the value
	# current choice point appears to depend on the most recent value returned by the parent choice point.
	# It will then set the ConditionalSampler to make the choice point conditional on the identified parent,
	# and then estimate the parameters of the underlying sampler (i.e. the original sampler in the model) for each
	# value of the parent choice point
	# (If the model were to contain RecursionDepthSamplers then the conditional dependencies on recursion depth in these samplers
	# would also estimated by this method.)
	print("Estimating conditional model ... ")
	estimateconditionalmodel(scm, selectedtraces)
	println("done")

end

println("Properties of sampler choice model after all EDA generations: ")
output_model_info(scm)


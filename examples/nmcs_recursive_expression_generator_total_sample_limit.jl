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



# Generate examples from unoptimized model
sampler_examples = [robustgen(gn, choicemodel=scm, maxchoices=MaxChoices) for i in 1:NumSamples]

# generate data using the optimised model
# BUT here we specify (compared to nmcs_resursive_expression_generator) more samples per choice point, but a limit of 50 on the total number of samples taken by NMCS
nmcs_examples = [robustgen(gn, choicemodel=NMCSChoiceModel(scm,fitnessfn,5, totalsamplelimit=50), maxchoices=MaxChoices) for i in 1:NumSamples]
# TODO: for the moment we need to create a fresh NMCS choice model on each run since it's stateful model
# NMCSChoiceModel(scm,fitnessfn,2) creates a choice model using the sampler choice model
# single level, samplesize of 2.
# Note that NMCSChoiceModel does not require a fitness function that handles the termination exception or, equivalently 
# when using robustgen, nothing as the value returned by the generator; instead this is handled internally by the 
# choice model.  However, the generator may still raise this exception (or return nothing when using robustgen) if 
# all simulations at a particular choice points are terminated by the exception

# Print examples so they can be compared
report(examples, desc) = begin
  mean_length = mean(map(robustlength, examples))
  println("\n", desc, " examples (avg. length = $mean_length):\n  ", 
    examples[1:min(10, length(examples))])
end
report(sampler_examples, "Sampler Choice Model")
report(nmcs_examples, "NMCS Choice Model (with Sampler Choice Model as policy)")

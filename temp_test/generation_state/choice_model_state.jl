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
NumSamples = 10

# Limit on the number of choices made per generation
MaxChoices = 200

# Target length and value of expressions
GoalLength = 40
GoalValue = 100pi

# handles length when string is nothing
robustlength(x) = x==nothing ? 1000 : length(x)
robusteval(x) = x==nothing ? 1000 : eval(parse(x))

# define a fitness function for NMCS
fitnessfn(x) = abs(GoalLength-robustlength(x)) + abs(GoalValue-robusteval(x))

# sampler choice model
scm = SamplerChoiceModel(gn)

# NMCS choice model
cm=NMCSChoiceModel(scm,fitnessfn,4)

# generate data using NMCS
for i in 1:NumSamples
  datum = robustgen(gn, choicemodel=cm, maxchoices=MaxChoices)
  println(datum)
end

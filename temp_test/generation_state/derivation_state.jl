using DataGenerators

@generator SimpleExprGen begin 
  start() = expression()
  expression() = operand() * " " * operator() * " " * operand()
  operand() = (choose(Bool) ? "-" : "") * join(plus(digit))
  digit() = string(choose(Int,0,9))
  operator() = "+"
  operator() = "-"
  operator() = "/"
  operator() = "*"
end


type MyDerivationState <: DataGenerators.DerivationState
	generator::DataGenerators.Generator
	choicemodel::DataGenerators.ChoiceModel
	godelsequence::Vector{Real} 		# Can be integers or floats
	cmtrace::Vector{Tuple{Integer,Dict}}	# choice point plus trace info returned from the choice model
	maxchoices::Int # upper limit on the size of the Godel sequence
	maxseqreps::Int # upper limit on the length of sequences from sequence choice points
	rulenamestack::Vector{Symbol} # stack of called rules - most recent at the end
	cpseqnumberstack::Vector{Vector{Int}} # corresponding to the rule name stack, the seq numbers of the encountered choice points
	# executiontreecoords::Vector{Int} # during the execution of a generator, this uniquely identifies the current rule in the execution tree
	# nextchildcoord::Int
	function MyDerivationState(g::DataGenerators.Generator, cm::DataGenerators.ChoiceModel, maxchoices::Int = MAX_CHOICES_DEFAULT, maxseqreps::Int = MAX_SEQ_REPS_DEFAULT)
		# new(g, cm, Vector{Real}[], Vector{Integer}[], maxchoices, maxseqreps, Vector{Symbol}(), Vector{Int}(), 1)
		new(g, cm, Vector{Real}[], Vector{Integer}[], maxchoices, maxseqreps, Vector{Symbol}(), Vector{Vector{Int}}())
	end
end

import DataGenerators.statetype
statetype(g::SimpleExprGen) = MyDerivationState

gn = SimpleExprGen()

x, state = generate(gn)

println("Emitted: $(x)")

dump(state)

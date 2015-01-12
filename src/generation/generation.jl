# A Generator represents the rules and meta information of a generator.
abstract Generator

# A choice model represents a way for how godel numbers are sampled during
# a derivation with a generator. A choice model only returns godel numbers, nothing more.
abstract ChoiceModel

# A DerivationState is created for every unique generation/derivation process. It
# collects info about the godel numbers (choices) and choice points
# as they are generated/taken. It can also provide information to the choice model
# for more complex time/state/depth related choices.
abstract DerivationState


#
# Abstract interface to all Generator sub-types. Override for specific behavior.
#
statetype(g::Generator) = g.statetype

subgenerator(g::Generator, index::Integer) = g.subgens[index]

# Return the meta information associated with a generator.
meta(g::Generator) = g.meta

# Return the choice point info associated with a generator. This includes both the choicepointinfo for
# the generator itself plus any subgenerators
function choicepointinfo(g::Generator)
	cpi = g.choicepointinfo
	for subgen in g.subgens
		merge!(cpi, subgen.choicepointinfo)
	end
	cpi
end


#
# Assumed interface to all subtypes of DerivationState. Override to implement more specific
# behavior.
#
generator(s::DerivationState) = s.generator

choicemodel(s::DerivationState) = s.choicemodel

function log(s::DerivationState, cpid::Integer, godelnumber::Real)
	push!(s.cpids, cpid)
	push!(s.godelsequence, godelnumber)
end

# A default derivation state that generators can use unless they need
# something more specific.
type DefaultDerivationState <: DerivationState
	generator::Generator
	choicemodel::ChoiceModel
	godelsequence::Vector{Real} 		# Can be integers or floats
	cpids::Vector{Integer}	# A choice point is identified by a unique integer number
	function DefaultDerivationState(g::Generator, cm::ChoiceModel)
		new(g, cm, Vector{Real}[], Vector{Integer}[])
	end
end


#
# Core functions to use generators once they have been defined.
#

# Generate an object from the generator using the startrule as entry point. 
# Uses the default choice model and creates a new state object unless one is given.
function generate(g::Generator; state = nothing, choicemodel = DefaultChoiceModel(), startrule = :start)
	state = (state == nothing) ? newstate(g, choicemodel) : state	
	startfunc = functionforrulenamed(g, startrule)
	# important: we evaluate in the current module since this (rather than GodelTest) will be where rule functions are defined
	result = eval(current_module(), Expr(:call, startfunc, g, state))
	return (result, state)
end

# Derived helper/convenience functions based on the core...
gen(g::Generator; state = nothing, choicemodel = DefaultChoiceModel()) = first(generate(g; state = state, choicemodel = choicemodel))
many(g, num = int(floor(rand() * 10))) = [gen(g) for i in 1:num]


#
# Choice point types
# These may be used by the choice model (for example, to determine a suitable marginal probability distribution for the choice point)
# They are passed BOTH in the call to querychoicemodel AND stored in as the :type in choicepointinfo.  To reduce the chance
# discrepancies, the types are defined globally here.
#
RULE_CP = :rule
VALUE_CP = :value
SEQUENCE_CP = :sequence


#
# Core choice point functions that have no short forms and should never be written directly in user code.
#


# choose a number (used by value choice points with numeric types: choose(Bool|Int|Float64|...))
function choosenumber(s::GodelTest.DerivationState, cpid, datatype, minval, maxval, paramsliteral)
	if !paramsliteral
		try
			minval = convert(datatype, minval)
		catch(InexactError)
			error("minimum value cannot be converted to a $(datatype) in choose_number")
		end
		try
			maxval = convert(datatype, maxval)
		catch(InexactError)
			error("maximum value cannot be converted to a $(datatype) in choose_number")
		end
		if maxval < minval
			error("maximum value is less than minimum in choose_number")
		end
	end
	querychoicemodel(s, VALUE_CP, cpid, datatype, minval, maxval)
end


# choose a number of repetitions (used by sequence choice points from constructs reps,mult,plus)
function choosereps(s::GodelTest.DerivationState, cpid, minreps, maxreps, paramsliteral)
	if !paramsliteral
		try
			minreps = convert(Int, minreps)
		catch(InexactError)
			error("minimum repetitions is not an integer in choose_reps")
		end
		try
			maxreps = convert(Int, maxreps)
		catch(InexactError)
			error("maximum repetitions is not an integer in choose_reps")
		end
		if minreps < 0
			error("minimum repetitions is less than zero in choose_reps")
		end
		if maxreps < minreps
			error("maximum repetitions is less than minimum in choose_reps")
		end
	end
	querychoicemodel(s, SEQUENCE_CP, cpid, Int, minreps, maxreps)	
end

# The (implicit) rule choice is implemented with this function. The short form is that
# the user writes rulename() at least two times in the generator code.
function chooserule(s::DerivationState, cpid, numrules)
	querychoicemodel(s, RULE_CP, cpid, Int, 1, numrules)
end


#
# Queries to the choice model
#

# ChoiceContext holds info about the current choice point such as its type and id number, and constraints such as the 
# minimum and maximum values that should be returned.  This information should be used by the choice model to return
# an appropriate Godel number.  
type ChoiceContext
	derivationstate::DerivationState
	cptype::Symbol
	cpid::Uint64
	datatype::DataType
	lowerbound::Real
	upperbound::Real
	# recursiondepth::Int # not currently implemented
end

# All queries to choice model to retrieve Godel numbers made via this function
# sets up ChoiceContext that may be used by choice model
function querychoicemodel(s::DerivationState, cptype, cpid, datatype, lowerbound, upperbound)
	# choicecontext = ChoiceContext(s, cptype, cpid, datatype, lowerbound, upperbound, 0)
	choicecontext = ChoiceContext(s, cptype, cpid, datatype, lowerbound, upperbound)
	# TODO recursiondepth
	gn = godelnumber(s.choicemodel, choicecontext)
	# since the log of godel numbers is used by choice models such as nested monte-carlo search to 'replay' a sequence,
	# it is arguably more robust to store the original (pre-conversion) vaue in the log
	log(s, cpid, gn)
	# convert the godel number to the specified type
	# this is most useful for choose_number to ensure returned value is of specified type
	# note that for Bool, convert treats 0 as false, and 1 as true
	convert(datatype, gn)
end


# Generate data from the subgenerator with given index.
subgen(g::Generator, s::DerivationState, index::Integer) = gen(subgenerator(g, index); state = s)


#
# Internal functions used by the core functions. They are not exported.
#

# Return the top-level function with the name ruleName
# Since rule functions have unique rule names to avoid issues with extending existing methods, need to look this up
function functionforrulenamed(g::Generator, rulename::Symbol)
	if !haskey(g.rulefunctionnames, rulename)
		error("generator has no rule named $(rulename)")
	end	
  g.rulefunctionnames[rulename]
end

# Create a new derivation state object for a given generator and choice model.
function newstate(g::Generator, choicemodel::ChoiceModel)
	st = statetype(g)
	st(g, choicemodel)
end
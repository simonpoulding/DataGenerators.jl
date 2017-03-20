# A Generator represents the rules and meta information of a generator.
abstract Generator

# A choice model represents a way for how godel numbers are sampled during
# a derivation with a generator. A choice model only returns godel numbers, nothing more.
abstract ChoiceModel

choicemodel(g::Generator) = g.choicemodel
setchoicemodel!(g::Generator, cm::ChoiceModel) = g.choicemodel = cm


# Return the choice point info associated with a generator. This includes both the choicepointinfo for
# the generator itself plus any subgenerators
function choicepointinfo(g::Generator)
	cpi = g.choicepointinfo
	for subgen in g.subgens
		merge!(cpi, subgen.choicepointinfo)
	end
	cpi
end


# A DerivationState is created for every unique generation/derivation process. It
# collects info about the godel numbers (choices) and choice points
# as they are generated/taken. It can also provide information to the choice model
# for more complex time/state/depth related choices.
abstract DerivationState


#
# Assumed interface to all subtypes of DerivationState. Override to implement more specific
# behavior.
#
generator(s::DerivationState) = s.generator

choicemodel(s::DerivationState) = choicemodel(generator(s))


# custom exception thrown when terminating generation
type GenerationTerminatedException <: Exception
	reason::AbstractString
	GenerationTerminatedException(reason::AbstractString) = new(reason)
end
Base.showerror(io::IO, e::GenerationTerminatedException) = print(io, "generation was terminated because ", e.reason);

# determines whether generation should continue or not
# the default behaviour is to terminate, by throwing a custom error, if the limit on the length of the godel sequence
# (i.e. number of choices made) would be exceeded
# this is useful in cleaning terminating when recursive generation would lead to a extremely large or infinite object
function checkterminationcriteria(s::DerivationState)
	if length(s.godelsequence) >= s.maxchoices
		throw(GenerationTerminatedException("number of the choices made exceeded $(s.maxchoices): specify a larger value of maxchoices as a parameter to generate"))
	end
end



function logchoicepoint(s::DerivationState, cpid::Integer, godelnumber::Real, trace::Dict)
	trace[:gdl] = godelnumber
	trace[:rul] = getcurrentrulename(s)
	push!(s.cmtrace, (cpid, trace))
	push!(s.godelsequence, godelnumber)
	pushcpseqnumber(s, length(s.godelsequence)) # sequence number is the new length of the godelsequence
end

	
# A default derivation state that generators can use unless they need
# something more specific.
type DefaultDerivationState <: DerivationState
	generator::Generator
	godelsequence::Vector{Real} 		# Can be integers or floats
	cmtrace::Vector{Tuple{Integer,Dict}}	# choice point plus trace info returned from the choice model
	maxchoices::Int # upper limit on the size of the Godel sequence
	maxseqreps::Int # upper limit on the length of sequences from sequence choice points
	maxruledepth::Int # upper limit on rule stack depth
	rulenamestack::Vector{Symbol} # stack of called rules - most recent at the end
	cpseqnumberstack::Vector{Vector{Int}} # corresponding to the rule name stack, the seq numbers of the encountered choice points
	# executiontreecoords::Vector{Int} # during the execution of a generator, this uniquely identifies the current rule in the execution tree
	# nextchildcoord::Int
	function DefaultDerivationState(g::Generator, maxchoices::Int, maxseqreps::Int, maxruledepth::Int)
		# new(g, cm, Vector{Real}[], Vector{Integer}[], maxchoices, maxseqreps, maxruledepth, Vector{Symbol}(), Vector{Int}(), 1)
		new(g, Vector{Real}[], Vector{Integer}[], maxchoices, maxseqreps, maxruledepth, Vector{Symbol}(), Vector{Vector{Int}}())
	end
end

#
# Abstract interface to all Generator sub-types. Override for specific behavior.
#
statetype(g::Generator) = DefaultDerivationState

subgenerator(g::Generator, index::Integer) = g.subgens[index]

# Return the meta information associated with a generator.
meta(g::Generator) = g.meta

#
# Operations on derivation state related to record rule execution trees and stacks
# 
# recordstartofrulemethod and recordendofrulemethod are written into rule methods by generator macro
# getcurrentrecursiondepth and getrecursiondepth can be called by, for example, a choice model (derivation state is accessible via the choice context)
# 
# Note this design permits record* methods to be reasonably fast, but get* methods are slower owing to need to count.  Could denormalise by  
# maintaining, for example, a dict of counts during record operations, but this would make the record methods - called by all rules - slower, while
# the get*depth methods - used only by SOME choice models - faster.
#
# "rule name stack" are the names (actually the unique method names assigned by the generator macro) of the ancestors of the current rule, including
# the currently executing rule as the last entry
# "cp seq number stack" for each rule in the stack, stores a vector of the seq nos of the choice points encountered in this rule
# this enable the ancestors (in terms of the call stack, rather than chronologically) to be determined, without storing
# large data structure 
#
# OBSOLETE - replaced with cpseqnumberstack which requires less momroy - but retaining these comments along with commented out code in case another use arises
# for these coords
# "execution tree coords" are a vector of numbers, e.g. [x, y, z] which identifies the current rule as the z^th 'child' rule executed by the y^th 
# child of the x^th child of the (abstract) root (x will always be 1, in fact).  Thus the immediate parent (i.e. calling) rule of a rule with coords
# [x, y, z] will have the coords [x, y]; siblings have [x, y, i!=z], descendants have [x, y, z, w, ...].
# note: the execution tree coord is unique for each *instance* of a rule being executed; the same generator rule may be executed multiple times during
# the execution of a generator, and each time it is executed, it will have different coords
#

# called at the start of generator method for each rule
recordstartofrule(s::DerivationState, rulename::Symbol) = begin
	if length(s.rulenamestack) >= s.maxruledepth
		throw(GenerationTerminatedException("rule depth exceeds the limit of $(s.maxruledepth): specify a larger value of maxruledepth as a parameter to generate"))
	end
	push!(s.rulenamestack, rulename)
	push!(s.cpseqnumberstack, Int[])
	# push!(s.executiontreecoords, s.nextchildcoord)
	# s.nextchildcoord = 1
	# println("Starting rule: $(rulename); coords: $(s.executiontreecoords); stack: $(s.rulenamestack)")
end

# called at the end of generator method for each rule
recordendofrule(s::DerivationState) = begin
	pop!(s.rulenamestack)
	# s.nextchildcoord = pop!(s.executiontreecoords) + 1
	pop!(s.cpseqnumberstack)
end

# the rule name (actually the "internal" unique method name) of the currently executing rule
# note: the unique method name is (ironically) the same for all rule with the same name (which occurs with an implicit rule choice
# in the generator) - this is achieved by having a single "umbrella" method which decides which of the rules with the same name to call
getcurrentrulename(s::DerivationState) = s.rulenamestack[end]

# the "depth" at the current rule (including the rule itself)
getruledepth(s::DerivationState) = length(s.rulenamestack)

# the recursion depth of a given rule (in terms of its immediate ancestor rules with the same name)
getrecursiondepth(s::DerivationState, rulename::Symbol) = count(r->r==rulename, s.rulenamestack)

# the recursion depth of the current rule (in terms of its immediate ancestor rules with the same name)
getcurrentrecursiondepth(s::DerivationState) = getrecursiondepth(s, getcurrentrulename(s))

# record new cp seq number
pushcpseqnumber(s::DerivationState, seqnumber::Int) = push!(s.cpseqnumberstack[end], seqnumber)

# get immediate ancestor cp seq number as the most recent seq number in the stack
getimmediateancestorcpseqnumber(s::DerivationState) = begin
	ancestorcpseqnumber = nothing
	i = length(s.cpseqnumberstack)
	while (ancestorcpseqnumber == nothing) && (i >= 1)
		if !isempty(s.cpseqnumberstack[i])
			ancestorcpseqnumber = s.cpseqnumberstack[i][end]
		end
		i -=  1
	end
	ancestorcpseqnumber
end

# # tests if execution tree coords indicate ancestry
# isexecutiontreeancestor(ancestorcoords::Vector{Int}, descendantcoords::Vector{Int}) =
# 	(length(ancestorcoords) < length(descendantcoords)) && (ancestorcoords == descendantcoords[1:length(ancestorcoords)])
#
# # tests if execution tree coords indicate ancestry or same
# isexecutiontreeselforancestor(ancestorcoords::Vector{Int}, descendantcoords::Vector{Int}) =
# 		(length(ancestorcoords) <= length(descendantcoords)) && (ancestorcoords == descendantcoords[1:length(ancestorcoords)])
#
# # tests if execution tree coords indicate parenthood
# isexecutiontreeparent(parentcoords::Vector{Int}, childcoords::Vector{Int}) = parentcoords == childcoords[1:end-1]

#
# Core functions to use generators once they have been defined.
#

# default parameters that can be overriden by user parameters to generate etc.
const defaultgenerateparams = Dict(
		:state => nothing,
		:resetchoicemodelstate => true,
		:startrule => :start,
		:maxchoices => 10017,
		:maxseqreps => 4868, 
		:maxruledepth => 11765)

# Generate an object from the generator using the startrule as entry point. 
# Uses the default choice model and creates a new state object unless one is given.
function generate(g::Generator; kwparams...)
	params = merge(defaultgenerateparams, Dict(p[1]=>p[2] for p in kwparams)) # kwparams takes priority
	state = (params[:state]  == nothing) ? newstate(g, params[:maxchoices], params[:maxseqreps], params[:maxruledepth]) : params[:state]
	if params[:resetchoicemodelstate]
		resetstate!(choicemodel(g))
	end
	startfunc = methodforrulenamed(g, params[:startrule])
	# important: we evaluate in the module that owns the type and since this (rather than DataGenerators) will be where rule functions are defined
	# the correct eval function is set in the generator on creation
	result = g.evalfn(Expr(:call, startfunc, g, state))
	(result, state)
end


choose(g::Generator; kwparams...) = first(generate(g; kwparams...))

# function choose(gt::DataType, userparams::Dict = Dict{Symbol, Any}())
# 	if !(super(gt) == Generator)
# 		error("choose(::DataType) is currently supported outside of generator code only when the datatype is a generator type")
# 	end
# 	g = gt()
# 	first(generate(g, userparams))
# end

# call generator and handle termination exception
# if termination occurs, return nothing as the object
function robustchoose(g::Generator; kwparams...)
	try
		return choose(g; kwparams...)
	catch e
		if isa(e, GenerationTerminatedException)
			return nothing
		else
			throw(e) # rethrow other types of error
		end
	end
end

# This enables a rule to be called indirectly by specifying its name as a symbol (plus any parameters)
# It is used by the type generators to workaround slow compilation times that appear to be a result of recursive type inference by "hiding" the call from the type inference algorithm
function indirectrulecall(g::Generator, s::DerivationState, rulename::Symbol, ruleparams...)
	if !haskey(g.rulemethodnames, rulename)
		throw(GenerationTerminatedException("no rule exists for requested name: $(rulename) in rule(...)"))
	end
	g.evalfn(Expr(:call, g.rulemethodnames[rulename], g, s, ruleparams...))
end



#
# Core choice point functions that have no short forms and should never be written directly in user code.
#


# choose a number (used by value choice points with numeric types: choose(Bool|Int|Float64|...))
function choosenumber(s::DerivationState, cpid, datatype, minval, maxval, paramsliteral)
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
	querychoicemodel(s, :value, cpid, datatype, minval, maxval)
end


# choose a number of repetitions (used by sequence choice points from constructs reps,mult,plus)
function choosereps(s::DerivationState, cpid, minreps, maxreps, paramsliteral)
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
	reps = querychoicemodel(s, :sequence, cpid, Int, minreps, maxreps)
	if reps > s.maxseqreps
		throw(GenerationTerminatedException("a sequence choice point made more than $(reps) repetitions and so exceeded the limit of $(s.maxseqreps): specify a larger value of maxseqrep as a parameter to generate"))
		# warn("choice model specified $(reps) repetitions for a sequence choice point, but this is being reduced to the maximum of $(s.maxseqreps) - specify a larger value of maxseqreps as a parameter to generate if this is not the required behaviour")
		# reps = s.maxseqreps
	end
	reps
end

# The (implicit) rule choice is implemented with this function. The short form is that
# the user writes rulename() at least two times in the generator code.
function chooserule(s::DerivationState, cpid, numrules)
	querychoicemodel(s, :rule, cpid, Int, 1, numrules)
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
	cpid::UInt64
	datatype::DataType
	lowerbound::Real
	upperbound::Real
end

# All queries to choice model to retrieve Godel numbers made via this function
# sets up ChoiceContext that may be used by choice model
function querychoicemodel(s::DerivationState, cptype, cpid, datatype, lowerbound, upperbound)
	# check if generation should continue or not - function raises an error if not
	checkterminationcriteria(s)
	# choicecontext = ChoiceContext(s, cptype, cpid, datatype, lowerbound, upperbound, 0)
	choicecontext = ChoiceContext(s, cptype, cpid, datatype, lowerbound, upperbound)
	# TODO recursiondepth
	gn, trace = godelnumber(choicemodel(s), choicecontext)
	@assert lowerbound <= gn <= upperbound
	logchoicepoint(s, cpid, gn, trace)
	# convert the godel number to the specified type
	# this is most useful for choose_number to ensure returned value is of specified type
	# note that for Bool, convert treats 0 as false, and 1 as true
	convert(datatype, gn)
end


# Generate data from the subgenerator with given index.
subgen(g::Generator, s::DerivationState, index::Integer) = choose(subgenerator(g, index); state = s)


#
# Internal functions used by the core functions. They are not exported.
#

# Return the top-level method for thhe rule
# Since rule method have unique names to avoid issues with extending existing methods, need to look this up
function methodforrulenamed(g::Generator, rulename::Symbol)
	if !haskey(g.rulemethodnames, rulename)
		error("generator has no rule named $(rulename)")
	end	
  g.rulemethodnames[rulename]
end

# Create a new derivation state object for a given generator and choice model.
function newstate(g::Generator, maxchoices::Int, maxseqreps::Int, maxruledepth::Int)
	st = statetype(g)
	st(g, maxchoices, maxseqreps, maxruledepth)
end
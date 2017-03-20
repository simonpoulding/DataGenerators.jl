#
# Nested Monte Carlo Search choice model
#
# constructor usage:
#
#		NCMSChoiceModel(choicemodel, fitnessfn, samplesize)
#
# where:
#	 choicemodel is an instance of another choice model (e.g. SamplerChoiceModel) used for simulating the outcome of choices
#  fitnessfn is a fitness function that takes a generated object as a parameter and returns a fitness where lower values are better
#  samplesize is the number of choices to sample when deciding on the value of each choice point
#
# example:
#		scm = SamplerChoiceModel(gn)
#		f = abs(size(x)-64)
#		ncm = NMCSChoiceModel(scm, f, 2)
#
# To implement higher level NMCS, use an NMCS instance as the policy choice model.  For example:
#		ncm2 = NMCSChoiceModel(NMCSChoiceModel(scm,f,2),f,2)
# specifies a 2-level NMCS
# While a little verbose, this can allow different sample sizes at different levels (and even different fitness functions).
#
# Note that NMCSChoiceModel does not require a fitness function that handles the termination exception (or, equivalently 
# when using robustgen, nothing as the value returned by the generator).  Instead this is handled internally by the 
# choice model.  However, the generator may still raise this exception (or return nothing when using robustgen) if 
# all simulations at a particular choice points are terminated by the exception
#

type NMCSChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	fitnessfunction::Function
	samplesize::Int 									# the (maximum) number of samples to take at each choice point
	minimumsamplesize::Int								# the minimum sample size (comes into effect when totalsamplelimit or ruledepthlimit is reached)
	totalsamplelimit::Int								# limit the total number of samples to take (does not include samples taken by nested samplers)
	ruledepthlimit::Int									# limit on generator rule depth
	totalsamplecount::Int								# number of samples taken in total so far
	bestfitness::Real 									# lower is better
	bestgodelsequence::Vector{Real} 					# the best godel sequence found so far
	besttracesequence::Vector{Dict}						# the traces for that sequence from the underlying choice model
	function NMCSChoiceModel(policychoicemodel::ChoiceModel, fitnessfunction::Function, samplesize::Int,  minimumsamplesize::Int, totalsamplelimit::Int, ruledepthlimit::Int)
		(minimumsamplesize >= 0) || error("Minimum sample size must be 0 or more")
		(minimumsamplesize <= samplesize) || error("Minimum sample size must be less or equal to the sample size")
		(totalsamplelimit >= 0) || error("Total sample count must be 0 or more")
		(ruledepthlimit >= 0) || error("Rule depth limit must be 0 or more")
		new(deepcopy(policychoicemodel), fitnessfunction, samplesize, minimumsamplesize, totalsamplelimit, ruledepthlimit, 0, +Inf, Real[], Dict[])
	end
end


function setnmcschoicemodel!(g::Generator, fitnessfunction::Function, samplesize::Int=1; minimumsamplesize::Int=0, totalsamplelimit::Int=typemax(Int), ruledepthlimit::Int=typemax(Int))
	setchoicemodel!(g, NMCSChoiceModel(choicemodel(g), fitnessfunction, samplesize, minimumsamplesize, totalsamplelimit, ruledepthlimit))
end

# reset any state 
function resetstate!(cm::NMCSChoiceModel)
	resetstate!(cm.policychoicemodel)
	cm.totalsamplecount = 0
	cm.bestfitness = +Inf
	cm.bestgodelsequence = (Real)[]
	cm.besttracesequence =  Dict[]
end

function godelnumber(cm::NMCSChoiceModel, cc::ChoiceContext)
	existinggodelsequence = cc.derivationstate.godelsequence
	existingtracesequence = map(t->t[2], cc.derivationstate.cmtrace) # cmtrace is tuples of cpid and trace for that cp; need here just the trace
	s = 0 # local sample count (for this choice point)
	# if total sample count is exceeded, no further samples are taken, and instead godel number
	# is taken from the best godel sequence found so far
	validruledepth = (cm.ruledepthlimit == typemax(Int)) ? true : getruledepth(cc.derivationstate) <= cm.ruledepthlimit
	while (s < cm.samplesize) && ((s < cm.minimumsamplesize) || ((validruledepth) && (cm.totalsamplecount < cm.totalsamplelimit)))
		s += 1
		cm.totalsamplecount += 1
		generator = deepcopy(cc.derivationstate.generator)
		simulationcm = NMCSSimulationChoiceModel(deepcopy(cm.policychoicemodel), deepcopy(existinggodelsequence), deepcopy(existingtracesequence))
		result, state = nothing, nothing
		try
			result, state = generate(generator; choicemodel=simulationcm, maxchoices=cc.derivationstate.maxchoices)
		catch e
		  if isa(e,GenerationTerminatedException)
				continue # skip the remainder of this loop iteration
			else
				throw(e)
			end
		end
		fitness = cm.fitnessfunction(result)
		if fitness <= cm.bestfitness # <= rather than < in order to improve diversity: if new sequence is just as good, prefer it to the stored best
			cm.bestfitness = fitness
			cm.bestgodelsequence = deepcopy(state.godelsequence)
			cm.besttracesequence = map(t->t[2], state.cmtrace) # cmtrace is tuples of cpid and trace for that cp; need here just the trace
		end
	end
	if isempty(cm.bestgodelsequence)
		# if all of the loop iterations above caught a GenerationTerminatedException AND this is the first choice point, then no bestsequence
		# is set - throw an exception since we cannot return a choice for the choice point
		throw(GenerationTerminatedException("for all simulations run at the first choice point in NMCS, the number of the choices made exceeded $(cc.derivationstate.maxchoices): specify a larger value of maxchoices as a parameter to generate, or increase the NMCS sample size"))
	end
	gn = cm.bestgodelsequence[length(cc.derivationstate.godelsequence)+1]
	trace = cm.besttracesequence[length(cc.derivationstate.cmtrace)+1]
	gn, trace
end

setparams!(cm::NMCSChoiceModel, params) = setparams!(cm.policychoicemodel, params)
getparams(cm::NMCSChoiceModel) = getparams(cm.policychoicemodel)
paramranges(cm::NMCSChoiceModel) = paramranges(cm.policychoicemodel)


type NMCSSimulationChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	presetgodelsequence::Vector{Real}
	presettracesequence::Vector{Dict}
end

function godelnumber(cm::NMCSSimulationChoiceModel, cc::ChoiceContext)
	if isempty(cm.presetgodelsequence)
		gn, trace = godelnumber(cm.policychoicemodel, cc)
	else
		gn, trace = shift!(cm.presetgodelsequence), shift!(cm.presettracesequence)
	end
	gn, trace
end

# reset any state 
function resetstate!(cm::NMCSSimulationChoiceModel)
	resetstate!(cm.policychoicemodel)
end

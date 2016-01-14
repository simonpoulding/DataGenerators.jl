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
	samplesize::Int 									# the number of samples to take
	bestfitness::Real 								# lower is better
	bestgodelsequence::Vector{Real} 	# the best godel sequence found so far
	function NMCSChoiceModel(policychoicemodel::ChoiceModel, fitnessfunction::Function, samplesize::Int=1)
		warn("NMCS variant")
		new(deepcopy(policychoicemodel), fitnessfunction, samplesize, +Inf, [])
	end
end


function godelnumber(cm::NMCSChoiceModel, cc::ChoiceContext)
	if cc.datatype <: Integer
		lowerbound = cc.lowerbound
		upperbound = cc.upperbound
		if (cc.cptype == SEQUENCE_CP) && ((upperbound - lowerbound + 1) > cm.samplesize)
			upperbound = lowerbound + cm.samplesize - 1
			# TODO: what about non-sequence with large ranges? handle like Real?
		end
	# TODO
	# elseif currentnode.datatype <: Real
	# 	while length(currentnode.childnodes) < 
	# 		# lowerbound = isfinite(cc.lowerbound) ? cc.lowerbound : sign(cc.lowerbound) * maxintfloat(cc.datatype) / 10
	# 		# upperbound = isfinite(cc.upperbound) ? cc.upperbound : sign(cc.upperbound) * maxintfloat(cc.datatype) / 10
	# 		# rangelen = convert(Float64,upperbound) - convert(Float64,lowerbound)
	# 		# gn = lowerbound + rand() * rangelen # note rand() returns a value in [0,1)
	# 	end
	else
		error("Unhandled datatype $(cc.datatype) for node to be expanded")
	end

	for childgn in lowerbound:upperbound
		policychoicemodel = deepcopy(cm.policychoicemodel)
		generator = deepcopy(cc.derivationstate.generator)
		presetgodelsequence = deepcopy(cc.derivationstate.godelsequence)
		push!(presetgodelsequence, childgn)
		simulationcm = NMCSSimulationChoiceModel(policychoicemodel, presetgodelsequence)
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
		if fitness <= cm.bestfitness
			cm.bestfitness = fitness
			cm.bestgodelsequence = deepcopy(state.godelsequence)
		end
	end
	if isempty(cm.bestgodelsequence)
		# if all of the loop iterations above caught a GenerationTerminatedException AND this is the first choice point, then no bestsequence
		# is set - throw an exception since we cannot return a choice for the choice point
		throw(GenerationTerminatedException("for all simulations run at the first choice point in NMCS, the number of the choices made exceeded $(cc.derivationstate.maxchoices): specify a larger value of maxchoices as a parameter to generate, or increase the NMCS sample size"))
	end
	gn = cm.bestgodelsequence[length(cc.derivationstate.godelsequence)+1]
	gn, Dict()
end

setparams(cm::NMCSChoiceModel, params) = setparams(cm.policychoicemodel, params)
getparams(cm::NMCSChoiceModel) = getparams(cm.policychoicemodel)
paramranges(cm::NMCSChoiceModel) = paramranges(cm.policychoicemodel)

type NMCSSimulationChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	presetgodelsequence::Vector{Real}
end

function godelnumber(cm::NMCSSimulationChoiceModel, cc::ChoiceContext)
	if isempty(cm.presetgodelsequence)
		gn, trace = godelnumber(cm.policychoicemodel, cc)
	else
		gn, trace = shift!(cm.presetgodelsequence), Dict()
	end
	gn, trace
end
export NMCSChoiceModel
export set_model_params, get_model_params, model_param_ranges

type NMCSChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	fitnessfunction::Function
	samplesize::Int 									# the number of samples to take
	bestfitness::Real 								# lower is better
	bestgodelsequence::Vector{Real} 	# the best godel sequence found so far
	function NMCSChoiceModel(policychoicemodel::ChoiceModel, fitnessfunction::Function, samplesize::Int=1)
		new(deepcopy(policychoicemodel), fitnessfunction, samplesize, +Inf, [])
	end
end


function godel_number(cm::NMCSChoiceModel, cc::ChoiceContext)
	# println()
	# println("-----------")
	for i in 1:cm.samplesize
		# println("SAMPLE: $(i)")
		policychoicemodel = deepcopy(cm.policychoicemodel)
		generator = deepcopy(cc.derivationstate.generator)
		presetgodelsequence = deepcopy(cc.derivationstate.godelsequence)
		# println("PRESETGODELSEQUENCE: $(cc.derivationstate.godelsequence)")
		simulationcm = NMCSSimulationChoiceModel(policychoicemodel, presetgodelsequence)
		# if typeof(policychoicemodel) == NMCSChoiceModel
		# 	println(">> LOWER-LEVEL NMCS")
		# 	println()
		# end
		(result, state) = generate(generator; choicemodel=simulationcm)
		# if typeof(policychoicemodel) == NMCSChoiceModel
		# 	println()
		# 	println("<< LOWER-LEVEL NMCS")
		# end
		fitness = cm.fitnessfunction(result)
		# println("RESULT: $(result)")
		# println("SEQUENCE: $(state.godelsequence)")
		# println("FITNESS: $(fitness)")
		if fitness <= cm.bestfitness
			cm.bestfitness = fitness
			cm.bestgodelsequence = deepcopy(state.godelsequence)
		end
		# println("BESTSEQUENCE: $(cm.bestgodelsequence)")
	end
	# println("GN: $(cm.bestgodelsequence[length(cc.derivationstate.godelsequence)+1])")
	cm.bestgodelsequence[length(cc.derivationstate.godelsequence)+1]
end

set_model_params(cm::NMCSChoiceModel, params) = set_model_params(cm.policychoicemodel, params)
get_model_params(cm::NMCSChoiceModel) = get_model_params(cm.policychoicemodel)
model_param_ranges(cm::NMCSChoiceModel) = model_param_ranges(cm.policychoicemodel)

type NMCSSimulationChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	presetgodelsequence::Vector{Real}
end

function godel_number(cm::NMCSSimulationChoiceModel, cc::ChoiceContext)
	if isempty(cm.presetgodelsequence)
		godel_number(cm.policychoicemodel, cc)
	else
		shift!(cm.presetgodelsequence)
	end
end
export LimiterChoiceModel
export set_model_params, get_model_params, model_param_ranges

type LimiterChoiceModel <: ChoiceModel
	childchoicemodel::ChoiceModel
	maxsequencelength::Int
	function LimiterChoiceModel(childchoicemodel::ChoiceModel, maxsequencelength::Int)
		new(deepcopy(childchoicemodel), maxsequencelength)
	end
end


function godel_number(cm::LimiterChoiceModel, cc::ChoiceContext)
	if length(cc.derivationstate.godelsequence) < cm.maxsequencelength
		godel_number(cm.childchoicemodel, cc)
	else
		0
	end
end

set_model_params(cm::LimiterChoiceModel, params) = set_model_params(cm.childchoicemodel, params)
get_model_params(cm::LimiterChoiceModel) = get_model_params(cm.childchoicemodel)
model_param_ranges(cm::LimiterChoiceModel) = model_param_ranges(cm.childchoicemodel)

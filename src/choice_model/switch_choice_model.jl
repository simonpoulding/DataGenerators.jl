type SwitchChoiceModel <: ChoiceModel
	casecms::Vector{Tuple{Vector{UInt}, ChoiceModel}}
	defaultcm::ChoiceModel
	function SwitchChoiceModel(casecms::Vector, defaultcm::ChoiceModel)
		new(casecms, defaultcm)
	end
end


function godelnumber(cm::SwitchChoiceModel, cc::ChoiceContext)
	for (cpids, casecm) in cm.casecms
		if cc.cpid in cpids
			return godelnumber(casecm, cc)
		end
	end	
	godelnumber(cm.defaultcm, cc)
end


function resetstate!(cm::SwitchChoiceModel)
	foreach(c->resetstate!(c[2]), cm.casecms)
	resetstate!(cm.defaultcm)
end


getparams(cm::SwitchChoiceModel) = [vcat(map(c->getparams(c[2]), cm.casecms)...); getparams(cm.defaultcm)]


function setparams!(cm::SwitchChoiceModel, params)
	if length(params) != numparams(cm)
		error("expected $(numparams(cm)) model parameter(s), but got $(length(params))")
	end
	startidx = 1
	for (cpids, casecm) in cm.casecms
		endidx = startidx + numparams(casecm) - 1
		if endidx >= startidx
			setparams!(casecm, params[startidx:endidx])
		end
		startidx = endidx + 1
	end	
	endidx = startidx + numparams(cm.defaultcm) - 1
	if endidx >= startidx
		setparams!(cm.defaultcm, params[startidx:endidx])
	end
end


paramranges(cm::SwitchChoiceModel) = [vcat(map(c->paramranges(c[2]), cm.casecms)...); paramranges(cm.defaultcm)]


show(io::IO, cm::SwitchChoiceModel) = print(io, "Switch choice model with cases: ", map(c->c[2], cm.casecms)..., "; default: ", cm.defaultcm)
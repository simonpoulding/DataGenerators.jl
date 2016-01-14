type MCTSNode
	totalreward::Real
	visitcount::Int
	cptype::Symbol
	datatype::DataType
	lowerbound::Real
	upperbound::Real
	childnodes::Dict{Real, MCTSNode}
	function MCTSNode()
		new(0.0, 0, :unknown, Nothing, 0.0, 0.0, Dict{Real,MCTSNode}())
	end
end

function printnode(node::MCTSNode, action::String="root", indent::Int=0)
	#DEBUG println(" "^(indent*2) * "$(action): totalreward: $(node.totalreward) visitcount: $(node.visitcount) cptype: $(node.cptype) datatype: $(node.datatype) lowerbound: $(node.lowerbound) upperbound: $(node.upperbound)")
	for godelnumber in keys(node.childnodes)
		printnode(node.childnodes[godelnumber], "$(godelnumber)", indent+1)
	end
end

type MCTSChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	rewardfunction::Function
	visitbudget::Int
	samplesize::Int 								# the number of samples to take
	cp::Real										# the constant C_p in the calculation of UCB1
	rootgodelsequence::Vector{Real} 				# defines the state of the current "root" node
	rootnode::MCTSNode 								# current root node
	function MCTSChoiceModel(policychoicemodel::ChoiceModel, rewardfunction::Function, visitbudget::Int=1, samplesize::Int=1, cp::Real=1/sqrt(2.0))
		new(deepcopy(policychoicemodel), rewardfunction, visitbudget, samplesize, cp, (Real)[], MCTSNode())
	end
end

function godelsequenceasstring(godelsequence::Vector{Real})
	s = ""
	for godelnumber in godelsequence
		s = s * "$(godelnumber) "
	end
	s
end

function printmodel(cm::MCTSChoiceModel)
	#DEBUG println("- START model")
	#DEBUG println("rootgodelsequence: $(godelsequenceasstring(cm.rootgodelsequence))")
	printnode(cm.rootnode)
	#DEBUG println("- END model")
	# readline()
end


# note: returns the godelnumber (i.e. action) of the best child node is returned, rather than the node itseld
function bestchildgodelnumber(node::MCTSNode, cp::Real)

	#DEBUG println("- START bestchildgodelnumber")
	#DEBUG println("using cp: $(cp)")
	@assert length(node.childnodes) >= 1

	bestucb1 = -Inf
	bestgodelnumbers = (Real)[]
	for childgodelnumber in keys(node.childnodes)
		childnode = node.childnodes[childgodelnumber]
		ucb1 = childnode.visitcount == 0 ? Inf : (childnode.totalreward / childnode.visitcount) + cp * sqrt(2 * Base.log(node.visitcount) / childnode.visitcount)
		#DEBUG println("godelnumber: $(childgodelnumber) ucb1: $(ucb1)")
		# TODO: fix why Base.log is required here
		if ucb1 > bestucb1
			bestucb1 = ucb1
			bestgodelnumbers = [childgodelnumber]
		elseif ucb1 == bestucb1
			push!(bestgodelnumbers, childgodelnumber)
		end
	end


	# return one of the 'best' godelnumbers
	@assert length(bestgodelnumbers) >= 1
	best = bestgodelnumbers[rand(1:length(bestgodelnumbers))]

	#DEBUG println("choose: $(best)")
	#DEBUG println("- END bestchildgodelnumber")
	best

end


function godelnumber(cm::MCTSChoiceModel, cc::ChoiceContext)

	#DEBUG println("---- START godelnumber")
	cm.rootnode = MCTSNode()
	cm.rootgodelsequence = deepcopy(cc.derivationstate.godelsequence)

	#DEBUG println("initial model:")
	#DEBUG printmodel(cm)

	if cm.rootnode.cptype == :unknown
		#DEBUG println("setting datatype for rootnode from choice context")
		cm.rootnode.cptype = cc.cptype
		cm.rootnode.datatype = cc.datatype
		cm.rootnode.lowerbound = cc.lowerbound
		cm.rootnode.upperbound = cc.upperbound
	end

	@assert cm.rootnode.cptype == cc.cptype
	@assert cm.rootnode.datatype == cc.datatype
	@assert cm.rootnode.lowerbound == cc.lowerbound
	@assert cm.rootnode.upperbound == cc.upperbound

	# keep on expanind and running simulations until the rootnode has been visited the required number of times

	#DEBUG println("---- START visiting")

	while cm.rootnode.visitcount < cm.visitbudget

		#DEBUG println("--- START visit iteration")

		currentnode = cm.rootnode
		currentgodelsequence = deepcopy(cm.rootgodelsequence)
		nodestoreward = [currentnode]
		reward = 0.0

		#DEBUG println("-- START finding node for simulation")

		# when current node can't be expanded, move to best child, until we find a node to expand (or terminal) node
		while (currentnode.cptype != :unknown) && (currentnode.cptype != :terminal)
			# unknown means it is a newly expanded node

			#DEBUG println("- START tree policy iteration")

			if length(currentnode.childnodes) == 0

				#DEBUG println(" START expansion")

				if currentnode.datatype <: Integer
					lowerbound = currentnode.lowerbound
					upperbound = currentnode.upperbound
					if (currentnode.cptype == SEQUENCE_CP) && ((upperbound - lowerbound + 1) > cm.samplesize)
						upperbound = lowerbound + cm.samplesize - 1
						# TODO: what about non-sequence with large ranges? handle like Real?
					end
					for childgodelnumber in lowerbound:upperbound
						#DEBUG println("expanding for godelnumber $(childgodelnumber)")
						currentnode.childnodes[childgodelnumber] = MCTSNode()
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
					error("Unknown datatype $(currentnode.datatype) for node to be expanded")
				end

				#DEBUG println("model after expansion")
				#DEBUG printmodel(cm)


				#DEBUG println(" END expansion")

			end

			childgodelnumber = bestchildgodelnumber(currentnode, cm.cp)
			#DEBUG println("best child godel number: $(childgodelnumber)")
			childnode = currentnode.childnodes[childgodelnumber]
			push!(nodestoreward, childnode)
			currentnode = childnode
			push!(currentgodelsequence, childgodelnumber)
			
			#DEBUG println("new godel sequence: $(godelsequenceasstring(currentgodelsequence))")

			#DEBUG println("- END tree policy iteration")

		end

		#DEBUG println("-- END finding node for simulation")


		#DEBUG println("-- START simulation")
		policychoicemodel = deepcopy(cm.policychoicemodel)
		generator = deepcopy(cc.derivationstate.generator)
		presetgodelsequence = deepcopy(currentgodelsequence)
		simulationcm = MCTSSimulationChoiceModel(policychoicemodel, presetgodelsequence, nothing)
		result, state = nothing, nothing

		#DEBUG println("simulation using sequence: $(godelsequenceasstring(presetgodelsequence))")

		try
			result, state = generate(generator; choicemodel=simulationcm, maxchoices=cc.derivationstate.maxchoices)
			reward = cm.rewardfunction(result)
		catch e
  			if !isa(e, GenerationTerminatedException)
				throw(e)
			end
			# TODO could punish further, e.g. negative reward?
		end

		@assert (state == nothing) || (length(state.godelsequence) >= length(currentgodelsequence))
		@assert (state == nothing) || (state.godelsequence[1:length(currentgodelsequence)] == currentgodelsequence)

		#DEBUG println("simulation result: $(result)")
		#DEBUG println("simulation reward: $(reward)")

		if typeof(simulationcm.firstNewChoiceContext) <: ChoiceContext
			currentnode.cptype = simulationcm.firstNewChoiceContext.cptype
			currentnode.datatype = simulationcm.firstNewChoiceContext.datatype
			currentnode.lowerbound = simulationcm.firstNewChoiceContext.lowerbound
			currentnode.upperbound = simulationcm.firstNewChoiceContext.upperbound
		else
			currentnode.cptype = :terminal
		end

		# backpropogate reward
		for nodetoreward in nodestoreward
			nodetoreward.totalreward += reward
			nodetoreward.visitcount += 1
		end

		#DEBUG println("model after applying simulation results:")
		#DEBUG printmodel(cm)
		#DEBUG println("--- END simulation")

		#DEBUG println("--- END visit iteration")

	end

	#DEBUG println("---- END visiting")

	#DEBUG println("model before choosing godel number:")
	#DEBUG printmodel(cm)

	# desired godelnumber is that of the best child of the current root
	gn = bestchildgodelnumber(cm.rootnode, 0.0) # NB with C_p of 0
	# the child with this godelnumber now becomes the root
	# cm.rootnode = cm.rootnode.childnodes[gn]
	# push!(cm.rootgodelsequence, gn)

	#DEBUG println("bounds: $(cc.lowerbound) $(cc.upperbound)")
	#DEBUG println("returning godelnumber: $(gn)")
	#DEBUG println("---- END godelnumber")

	gn, Dict()

end

setparams(cm::MCTSChoiceModel, params) = setparams(cm.policychoicemodel, params)
getparams(cm::MCTSChoiceModel) = getparams(cm.policychoicemodel)
paramranges(cm::MCTSChoiceModel) = paramranges(cm.policychoicemodel)


type MCTSSimulationChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	presetgodelsequence::Vector{Real}
	firstNewChoiceContext::Union(Nothing,ChoiceContext)
end

function godelnumber(cm::MCTSSimulationChoiceModel, cc::ChoiceContext)
	if isempty(cm.presetgodelsequence)
		if !(typeof(cm.firstNewChoiceContext) <: ChoiceContext)
			cm.firstNewChoiceContext = deepcopy(cc)
		end
		gn, trace = godelnumber(cm.policychoicemodel, cc)
	else
		gn, trace = shift!(cm.presetgodelsequence), Dict()
	end
	gn, trace
end
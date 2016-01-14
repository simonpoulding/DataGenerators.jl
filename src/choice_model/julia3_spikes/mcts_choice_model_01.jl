type MCTSNode
	totalreward::Real
	visitcount::Int
	samplecount::Int
	childnodes::Dict{Real, MCTSNode}
	function MCTSNode()
		new(0.0, 0, 0, Dict{Real,MCTSNode}())
	end
end

function printnode(node::MCTSNode, action::String="root", indent::Int=0)
	# println(" "^(indent*2) * "$(action): totalreward: $(node.totalreward) visitcount: $(node.visitcount) samplecount: $(node.samplecount)")
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
	# println("- START model")
	# println("rootgodelsequence: $(godelsequenceasstring(cm.rootgodelsequence))")
	printnode(cm.rootnode)
	# println("- END model")
	# readline()
end


# note: returns the godelnumber (i.e. action) of the best child node is returned, rather than the node itseld
function bestchildgodelnumber(node::MCTSNode, cp::Real)

	# println("- START bestchildgodelnumber")
	# println("using cp: $(cp)")
	@assert length(node.childnodes) >= 1

	bestucb1 = -Inf
	bestgodelnumbers = (Real)[]
	for childgodelnumber in keys(node.childnodes)
		childnode = node.childnodes[childgodelnumber]
		@assert childnode.visitcount >= 1
		ucb1 = (childnode.totalreward / childnode.visitcount) + cp * sqrt(2 * Base.log(node.visitcount) / childnode.visitcount)
		# println("godelnumber: $(childgodelnumber) ucb1: $(ucb1)")
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

	# println("choose: $(best)")
	# println("- END bestchildgodelnumber")
	best

end


function godelnumber(cm::MCTSChoiceModel, cc::ChoiceContext)

	# println("---- START godelnumber")

	# println("initial model:")
	# printmodel(cm)

	# keep on expanind and running simulations until the rootnode has been visited the required number of times

	# println("---- START visiting")

	while cm.rootnode.visitcount < cm.visitbudget

		# println("--- START visit iteration")

		currentnode = cm.rootnode
		currentgodelsequence = deepcopy(cm.rootgodelsequence)
		nodestoreward = [currentnode]
		reward = 0.0

		# println("-- START finding expandable node")

		# when current node can't be expanded, move to best child, until we find an expandable (or terminal) node
		while ((currentnode.samplecount == cm.samplesize) || ((cc.datatype <: Integer) && (length(currentnode.childnodes) == (cc.upperbound - cc.lowerbound + 1)))) && (length(currentnode.childnodes) > 0)
			# println("-- START expandable node iteration")
			childgodelnumber = bestchildgodelnumber(currentnode, cm.cp)
			# println("best child godel number: $(childgodelnumber)")
			childnode = currentnode.childnodes[childgodelnumber]
			push!(nodestoreward, childnode)
			currentnode = childnode
			push!(currentgodelsequence, childgodelnumber)
			# println("new godel sequence: $(godelsequenceasstring(currentgodelsequence))")
			# println("-- END expandable node iteration")
		end

		# println("expanding from sequence : $(godelsequenceasstring(currentgodelsequence))")
		# println("-- END finding expandable node")

		# now at a child node that can be expanded
		# perform a simulation that:
		#  (1) expand current node according to probability distribution of policy choice model
		#      - this is because we don't know set of possible actions from current state (and
		#      indeed this set may be uncountable), so we sample in a similar way to the NMCS
		#      implementation
		#  (2) apply the default policy to the end state

		# println("-- START simulation")

		policychoicemodel = deepcopy(cm.policychoicemodel)
		generator = deepcopy(cc.derivationstate.generator)
		presetgodelsequence = deepcopy(currentgodelsequence)
		simulationcm = MCTSSimulationChoiceModel(policychoicemodel, presetgodelsequence)
		result, state = nothing, nothing

		# println("simulation using sequence: $(godelsequenceasstring(presetgodelsequence))")

		try
			result, state = generate(generator; choicemodel=simulationcm, maxchoices=cc.derivationstate.maxchoices)
			reward = cm.rewardfunction(result)
		catch e
  			if !isa(e, GenerationTerminatedException)
				throw(e)
			end
			# TODO could punish further, e.g. negative reward?
		end

		# println("simulation result: $(result)")
		# println("simulation reward: $(reward)")
		# println("-- END simulation")

		# println("-- START applying simulation results")

		if state != nothing

			currentnode.samplecount += 1

			# println("godelsequence at end of simulation: $(godelsequenceasstring(state.godelsequence))")

			@assert length(state.godelsequence) >= length(currentgodelsequence)
			@assert state.godelsequence[1:length(currentgodelsequence)] == currentgodelsequence

			# check that a new godel number was returned (i.e. currentnode is not a terminal state)
			if length(state.godelsequence) > length(currentgodelsequence)

				# check which action (godelnumber) was taken next in the simulation
				childgodelnumber = state.godelsequence[length(currentgodelsequence)+1]

				# println("first godel number in simulation: $(childgodelnumber)")


				# check to see if node for this action has already been created
				if haskey(currentnode.childnodes, childgodelnumber)
					# println("first godel number is for existing child node")
					childnode = currentnode.childnodes[childgodelnumber]
				else
					# println("first godel number is for new child node")
					childnode = MCTSNode()
					currentnode.childnodes[childgodelnumber] = childnode
				end

				push!(nodestoreward, childnode)

				currentnode = childnode # not necessary?
				push!(currentgodelsequence, childgodelnumber) # not necessary?

			end

			# now backpropogate reward
			for nodetoreward in nodestoreward
				nodetoreward.totalreward += reward
				nodetoreward.visitcount += 1
			end

		end

		# println("model after applying simulation results:")
		# printmodel(cm)


		# println("-- END applying simulation results")

		# println("--- END visit iteration")

	end

	# println("---- END visiting")

	# println("model before choosing godel number:")
	# printmodel(cm)

	# desired godelnumber is that of the best child of the current root
	gn = bestchildgodelnumber(cm.rootnode, 0.0) # NB with C_p of 0
	# the child with this godelnumber now becomes the root
	cm.rootnode = cm.rootnode.childnodes[gn]
	push!(cm.rootgodelsequence, gn)

	# println("bounds: $(cc.lowerbound) $(cc.upperbound)")
	# println("returning godelnumber: $(gn)")
	# println("---- END godelnumber")

	gn, Dict()

end

setparams(cm::MCTSChoiceModel, params) = setparams(cm.policychoicemodel, params)
getparams(cm::MCTSChoiceModel) = getparams(cm.policychoicemodel)
paramranges(cm::MCTSChoiceModel) = paramranges(cm.policychoicemodel)


type MCTSSimulationChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	presetgodelsequence::Vector{Real}
end

function godelnumber(cm::MCTSSimulationChoiceModel, cc::ChoiceContext)
	if isempty(cm.presetgodelsequence)
		gn, trace = godelnumber(cm.policychoicemodel, cc)
	else
		gn, trace = shift!(cm.presetgodelsequence), Dict()
	end
	gn, trace
end
#
# MCTS (Monte Carlo Tree Search) Choice Model
#
# Note that this implementation has the following features:
#
#   - the "reward" function is assumed to provide a value from 0 to 1, with 1 the best value (other limits will probably work,
#     though); note that higher being better is the opposite direction from the NMCS implementation's "fitness" function
#
#   - since in GödelTest somce choice points have infinite support, it is not possible to exhaustively enumerate all children
#	  therefore we sample (with replacement) according to the policy choice model (the number of samoples controlled by the
#     samplesize parameter); this is for consistency how this "finitization" problem is handled with the NMCS implementation;
#     see the julia3_spikes directory for alternative implementations that (in a prototypical manner) finitise by simply placing
#     an upper bound on the number of children and so can enumerate without sampling [note: these spikes Julia 3 code, and may
#     also have some other functional differences]
#
#	- while the standard UCB1 metric is used to control exploration vs exploitation, the godel number (the next "move") is returned
#     by taking the child node of the root that found the best reward (rather than best average reward); this is because GödelTes
#     is a single-player "game" and so we have the control to realise this reward
#

type MCTSNode
	trace::Dict
	totalreward::Real
	maxreward::Real
	visitcount::Int
	samplecount::Int
	childnodes::Dict{Real, MCTSNode}
	function MCTSNode(trace::Dict)
		new(trace, 0.0, -Inf, 0, 0, Dict{Real,MCTSNode}())
	end
end

#DEBUG function printnode(node::MCTSNode, action::AbstractString="root", indent::Int=0)
	#DEBUG println(" "^(indent*2) * "$(action): totalreward: $(node.totalreward) maxreward: $(node.maxreward) visitcount: $(node.visitcount) samplecount: $(node.samplecount)")
#DEBUG	for godelnumber in keys(node.childnodes)
#DEBUG		printnode(node.childnodes[godelnumber], "$(godelnumber)", indent+1)
#DEBUG 	end
#DEBUG end


type MCTSChoiceModel <: ChoiceModel
	policychoicemodel::ChoiceModel
	rewardfunction::Function						# higher is better
	visitbudget::Int
	samplesize::Int 								# the number of samples to take
	cp::Real										# the constant C_p in the calculation of UCB1
	rootgodelsequence::Vector{Real} 				# defines the state of the current "root" node
	rootnode::MCTSNode 								# current root node
	function MCTSChoiceModel(policychoicemodel::ChoiceModel, rewardfunction::Function, visitbudget::Int=1, samplesize::Int=1, cp::Real=1/sqrt(2.0))
		new(deepcopy(policychoicemodel), rewardfunction, visitbudget, samplesize, cp, (Real)[], MCTSNode(Dict()))
	end
end


function mctschoicemodel!(g::Generator, rewardfunction::Function, visitbudget::Int=1, samplesize::Int=1, cp::Real=1/sqrt(2.0))
	setchoicemodel!(g, MCTSChoiceModel(choicemodel(g), rewardfunction, visitbudget, samplesize, cp))
end

# reset any state 
function resetstate!(cm::MCTSChoiceModel)
	resetstate!(cm.policychoicemodel)
	cm.rootgodelsequence = (Real)[]
	cm.rootnode = MCTSNode(Dict())
end

#DEBUG function godelsequenceasstring(godelsequence::Vector{Real})
#DEBUG 	s = ""
#DEBUG 	for godelnumber in godelsequence
#DEBUG 		s = s * "$(godelnumber) "
#DEBUG 	end
#DEBUG 	s
#DEBUG end

#DEBUG function printmodel(cm::MCTSChoiceModel)
	#DEBUG println("- START model")
	#DEBUG println("rootgodelsequence: $(godelsequenceasstring(cm.rootgodelsequence))")
#DEBUG 	printnode(cm.rootnode)
	#DEBUG println("- END model")
#DEBUG 	readline()
#DEBUG end


# note: returns the godelnumber (i.e. action) of the best child node is returned, rather than the node itseld
function bestchildgodelnumber(node::MCTSNode, cp::Real)

	#DEBUG println("- START bestchildgodelnumber")
	#DEBUG println("using cp: $(cp)")

	@assert length(node.childnodes) >= 1

	bestucb1 = -Inf
	bestgodelnumbers = (Real)[]
	for childgodelnumber in keys(node.childnodes)
		childnode = node.childnodes[childgodelnumber]
		@assert childnode.visitcount >= 1
		ucb1 = (childnode.totalreward / childnode.visitcount) + cp * sqrt(2 * Base.log(node.visitcount) / childnode.visitcount)
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

	#DEBUG println("- START godelnumber")

	#DEBUG println("initial model:")
	#DEBUG printmodel(cm)

	@assert isempty(cm.rootgodelsequence) || (cm.rootgodelsequence == cc.derivationstate.godelsequence)
	cm.rootgodelsequence = deepcopy(cc.derivationstate.godelsequence)

	# keep on expanind and running simulations until the rootnode has been visited the required number of times

	while cm.rootnode.visitcount < cm.visitbudget

		currentnode = cm.rootnode
		currentgodelsequence = deepcopy(cm.rootgodelsequence)
		nodestoreward = [currentnode]
		reward = 0.0

		# when current node can't be expanded, move to best child, until we find an expandable (or terminal) node
		while (currentnode.samplecount == cm.samplesize) && !isempty(currentnode.childnodes) 
			#DEBUG println("- START expandable node iteration")
			childgodelnumber = bestchildgodelnumber(currentnode, cm.cp)
			childnode = currentnode.childnodes[childgodelnumber]
			push!(nodestoreward, childnode)
			currentnode = childnode
			push!(currentgodelsequence, childgodelnumber)
			#DEBUG println("new godel sequence: $(godelsequenceasstring(currentgodelsequence))")
			#DEBUG println("- END expandable node iteration")
		end


		# now at a child node that can be expanded
		# perform a simulation that:
		#  (1) expand current node according to probability distribution of policy choice model
		#      - this is because we don't know set of possible actions from current state (and
		#      indeed this set may be uncountable), so we sample in a similar way to the NMCS
		#      implementation
		#  (2) apply the default policy to the end state

		#DEBUG println("- START simulation")

		policychoicemodel = deepcopy(cm.policychoicemodel)
		generator = deepcopy(cc.derivationstate.generator)
		presetgodelsequence = deepcopy(currentgodelsequence)
		simulationcm = MCTSSimulationChoiceModel(policychoicemodel, presetgodelsequence)
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
		
		#DEBUG println("simulation result: $(result)")
		#DEBUG println("simulation reward: $(reward)")
		#DEBUG println("- END simulation")


		if state != nothing

			#DEBUG println("- START applying simulation results")

			#DEBUG println("simulation returned sequence: $(godelsequenceasstring(state.godelsequence))")
		
			currentnode.samplecount += 1

			@assert length(state.godelsequence) >= length(currentgodelsequence)
			@assert state.godelsequence[1:length(currentgodelsequence)] == currentgodelsequence

			# check that a new godel number was returned (i.e. currentnode is not a terminal state)
			if length(state.godelsequence) > length(currentgodelsequence)

				# check which action (godelnumber) was taken next in the simulation
				childgodelnumber = state.godelsequence[length(currentgodelsequence)+1]

				#DEBUG println("first godel number in simulation: $(childgodelnumber)")

				# check to see if node for this action has already been created
				if haskey(currentnode.childnodes, childgodelnumber)
					#DEBUG println("first godel number is for existing child node")
					childnode = currentnode.childnodes[childgodelnumber]
				else
					#DEBUG println("first godel number is for new child node")
					# get choice point trace info for the child godel number: this will be the trace
					# info returned should this godel number be selected
					cptrace = state.cmtrace[length(currentgodelsequence)+1] 
					childnode = MCTSNode(cptrace[2]) # cptrace is tuple of cp id and trace info for the returned gn, so need the second element of the tuple
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
				if reward > nodetoreward.maxreward
					nodetoreward.maxreward = reward
				end
			end
			
			#DEBUG println("model after applying simulation results:")
			#DEBUG printmodel(cm)


			#DEBUG println("- END applying simulation results")

		end

		#DEBUG println("- END visit iteration")

	end

	# Taking desired godelnumber as that of the best child of the current root
	# is an ALTERNATIVE to the code below that finds max reward (and may be better for
	# the "single-player" game used here as we can ensure we makes moves to get this
	# max reward rather than the average reward)
	# gn = bestchildgodelnumber(cm.rootnode, 0.0) # NB with C_p of 0

	# desired godelnumber is that of the child with the largest maxreward
	bestmaxreward = -Inf
	bestgodelnumbers = (Real)[]
	for childgodelnumber in keys(cm.rootnode.childnodes)
		childnode = cm.rootnode.childnodes[childgodelnumber]	
		if childnode.maxreward > bestmaxreward
			bestmaxreward = childnode.maxreward
			bestgodelnumbers = [childgodelnumber]
		elseif childnode.maxreward == bestmaxreward
			push!(bestgodelnumbers, childgodelnumber)
		end
	end

	# return one of the 'best' godelnumbers
	@assert length(bestgodelnumbers) >= 1
	gn = bestgodelnumbers[rand(1:length(bestgodelnumbers))]
	trace = cm.rootnode.childnodes[gn].trace

	# the child with this godelnumber now becomes the root
	cm.rootnode = cm.rootnode.childnodes[gn]
	push!(cm.rootgodelsequence, gn) # not strictly necessary since set from cc on entry (but needed now for assert)

	#DEBUG println("bounds: $(cc.lowerbound) $(cc.upperbound)")
	#DEBUG println("returning godelnumber: $(gn)")

	gn, trace

end

setparams!(cm::MCTSChoiceModel, params) = setparams!(cm.policychoicemodel, params)
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

# reset any state 
function resetstate!(cm::MCTSSimulationChoiceModel)
	resetstate!(cm.policychoicemodel)
end

show(io::IO, cm::MCTSChoiceModel) = print(io, "MCTS choice model (policy: ", cm.policychoicemodel, ")")



function transform_bnf_ast(ast::ASTNode, startvariable)

  variabledefs = Dict{AbstractString,ASTNode}()

  # check that a rule exists for all variables referenced by other rules
  process_bnf_variabledef_nodes(ast, variabledefs)
  process_bnf_variableref_nodes(ast, variabledefs)

  # shrink choices and concatenation of just one
  process_bnf_alternation_nodes(ast)
  process_bnf_concatenation_nodes(ast)
  
  # add warnings to negation
  process_bnf_negation_nodes(ast)
  
  # add start rule as reference to root to enable reachability check
  if haskey(variabledefs, startvariable)
    push!(ast.refs, variabledefs[startvariable])
  else
    error("start variable $(startvariable) does not have a rule defined")
  end
  
end

function process_bnf_variabledef_nodes(parentnode::ASTNode, variabledefs)
	for node in parentnode.children
		if node.func == :variabledef
			if !haskey(variabledefs, node.args[:name])
				variabledefs[node.args[:name]] = node
			else
				error("Multiple rules for variable $(node.args[:name])")
				# TODO alternatively, could combine using a choice?
			end
		end
		# really no need to recurse: defs should only be possible as children of the root
		process_bnf_variabledef_nodes(node, variabledefs)
	end
end


function process_bnf_variableref_nodes(parentnode::ASTNode, variabledefs)
	for node in parentnode.children
		if node.func == :variableref
	  			if haskey(variabledefs, node.args[:name])
				push!(node.refs, variabledefs[node.args[:name]])
			else
				error("Rule not found for variable $(node.args[:name])")
			end
		end
		process_bnf_variableref_nodes(node, variabledefs)
	end
end


function process_bnf_alternation_nodes(parentnode::ASTNode)
	for idx in 1:length(parentnode.children)
		node = parentnode.children[idx]
		process_bnf_alternation_nodes(node)
		if node.func == :alternation
			if length(node.children) == 1
				# flatten if a single child since no need for a choice
				parentnode.children[idx] = node.children[1]
			end
		end
	end
end


function process_bnf_concatenation_nodes(parentnode::ASTNode)
	for idx in 1:length(parentnode.children)
		node = parentnode.children[idx]
		process_bnf_concatenation_nodes(node)
		if node.func == :concatenation
			if length(node.children) == 1
				# flatten if a single child since no need for a concatentation
				parentnode.children[idx] = node.children[1]
			end
		end
	end
end

function process_bnf_negation_nodes(parentnode::ASTNode)
	for node in parentnode.children
		if node.func == :negation
			warn(node, "currently do not handle negation (~): will simply output a space character")
		end
		process_bnf_negation_nodes(node)
	end
end


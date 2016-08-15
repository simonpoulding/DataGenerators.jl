# transforms choose(<string type>, regex) into a block of statements using GödelTest constructs

# TODO: currently PERL-style with XSD extensions
# TODO: tokenspace (UTF-8) - currently assumes ASCII
# TODO: Unicode character classes
# TODO: optimise ast (e.g. OR with only 1 child; consecutive terminals)

# entry point from main set of generator macro functions
function transformchoosestring(regex, datatype, gencontext::GeneratorContext)
	
	# currently wildcards assume ASCII
	if !(datatype <: ASCIIString)
		warn("regular expression wildcard and character classes are currently limited to ASCII in choose($(datatype),...)")
	end
	
	# build AST tree
	ast = regexparse(regex)
	
	# construct methods that implement generator for regex
	methods = regexconstructmethods(ast, gencontext)
	
	# add method to call entry point to regex methods, and convert output to desired datatype
	startmethodcall = Expr(:call, ast.methodname, gencontext.genparam, gencontext.stateparam)
	convertstmt = :( convert($datatype, $startmethodcall) )
	stmts = [methods; convertstmt]
	
	# join methods and convert statement into a single block
	Expr(:block, stmts...)
		
end

# node in AST formed by passing regex
type RegexASTNode
  func::Symbol
  children::Vector{RegexASTNode}	
  args::Dict{Symbol,Any}
  methodname::Symbol
end

function RegexASTNode(func::Symbol)
  RegexASTNode(func, Vector{RegexASTNode}(), Dict{Symbol,Any}(), gensym(string(func)))
end

# parse regex into an AST
function regexparse(regex::AbstractString)
		ast, pos = regexparseexpression(regex)
		ast
end

# parse an expression within the regex
function regexparseexpression(regex::AbstractString, pos=1)

	rootexpr = (pos==1)
	ornode = RegexASTNode(:or)
	andnode = RegexASTNode(:and)
	push!(ornode.children, andnode)

	escaped = false
	endofexpr = isempty(regex)

	while (!endofexpr)

		if pos > sizeof(regex)
			error("end of regex reached before parsing of expression complete")
		end

		chr = regex[pos]
		pos = nextind(regex, pos)

		if (chr=='\\') && (!escaped)
			escaped = true
		else

			if (chr=='|') && (!escaped)

				finishandnode(andnode)
				andnode = RegexASTNode(:and)
				push!(ornode.children, andnode)

			elseif (chr=='(') && (!escaped)

				exprnode, pos = regexparseexpression(regex, pos)
				push!(andnode.children, exprnode)

			elseif (chr==')') && (!escaped)
				if rootexpr
					error("additional right parenthesis encountered")
				end
				endofexpr = true

			elseif (chr in ['?']) && (!escaped)

				if isempty(andnode.children)
					error("no preceding item to apply $(chr) to")
				end
				
				precedingnode = pop!(andnode.children)

				optionalnode = RegexASTNode(:optional)
				push!(optionalnode.children, precedingnode)
				
				push!(andnode.children, optionalnode)

			elseif (chr in ['+', '*', '{']) && (!escaped)

				if isempty(andnode.children)
					error("no preceding item to apply $(chr) to")
				end

				precedingnode = pop!(andnode.children)

				quantifiernode = RegexASTNode(:quantifier)
				push!(quantifiernode.children, precedingnode)

				if chr=='{'

					quantifiernode.args[:lowerbound], pos = regexparseint(regex::AbstractString, pos)
					if (pos<=sizeof(regex)) && (regex[pos]==',')
						pos = nextind(regex,pos)
						if pos<=sizeof(regex)
							if regex[pos]=='}'
								quantifiernode.args[:upperbound] = typemax(Int)
							else
								quantifiernode.args[:upperbound], pos = regexparseint(regex::AbstractString, pos)
							end
						end
					else
						quantifiernode.args[:upperbound] = quantifiernode.args[:lowerbound]
					end
					if (pos>sizeof(regex)) || (regex[pos]!='}')
						error("end of regex reached before parsing of quantifier expression complete")
					else
						pos = nextind(regex,pos)
					end

				else

					quantifiernode.args[:lowerbound] = (chr=='+') ? 1 : 0
					quantifiernode.args[:upperbound] = typemax(Int)

				end

				push!(andnode.children, quantifiernode)

			elseif (chr=='[') && (!escaped)

				bracketnode, pos = regexparsebracket(regex, pos)
				push!(andnode.children, bracketnode)

			elseif ((chr in ['s', 'S', 'd', 'D', 'w', 'W', 'i', 'I', 'c', 'C']) && (escaped)) ||
							(chr in ['.'] && (!escaped))
				
				# TODO implicitly here, set of tokenspace is 9:10,13:13,32:126 - tab, new line, carriage return, plus printable ASCII
				# TODO to what extent should ASCII control characters be included? - here have tab (9), new line (10) and carriage return (13)
				# TODO strictly whitespace can include vertical tab (11) and form feed (13), but XML definition excludes them
				# TODO strictly wildcard (.) excludes just new line; but XML also excludes carriage return
				if chr == 's'  # whitespace: space, tab, carriage return, new line
					classspace = (UnitRange)[9:10,13:13,32:32]  	
	      elseif chr == 'S'  # non-whitespace
	        classspace = (UnitRange)[33:126]							
				elseif chr == 'd'  # digits (currently just ASCII digits)
		      classspace = (UnitRange)[48:57]								
		    elseif chr == 'D'  # non-digits
					classspace = (UnitRange)[9:10,13:13,32:47,58:126]
				elseif chr == 'w'  # word characters: letters, digits, plus underscore
		      classspace = (UnitRange)[48:57,65:90,95:95,97:122] 
		    elseif chr == 'W'  # non-word characters
					classspace = (UnitRange)[9:10,13:13,32:47,58:64,91:94,96:96,123:126]
				elseif chr == 'i'  # XSD extension - initial name characters: letters, plus hyphen
		      classspace = (UnitRange)[45:45,65:90,97:122] 
		    elseif chr == 'I'  # XSD extension - not initial name characters
					classspace = (UnitRange)[9:10,13:13,32:44,46:64,91:96,123:126]
				elseif chr == 'c'  # XSD extension - name characters: letters, digits, plus hyphen, period, colon
		      classspace = (UnitRange)[45:46,48:58,65:90,97:122] 
		    elseif chr == 'C'  # XSD extension - not name characters
					classspace = (UnitRange)[9:10,13:13,32:44,47:47,59:64,91:96,123:126]
	      else
	        classspace = (UnitRange)[9:9,32:126] # wildcard (.) - excludes new line and -- for XML -- carriage return
					# (Note: see also handling below of the empty expression which allows strings of any characters, including LF/CR)
					if chr != '.'
						warn("cannot process character class $(node.args[:value]) - using wildcard instead")
					end
	      end

				bracketnode = RegexASTNode(:bracket)
	      bracketnode.func = :bracket

	      for range in classspace
	        rangenode = RegexASTNode(:range)
	        rangenode.args[:value] = range
	        push!(bracketnode.children, rangenode)
				end

				push!(andnode.children, bracketnode)
				
			elseif (chr in ['^','$'] && (!escaped))
				
				# ignore: ^ and $ have no meaning in generation context TODO?

			else

				terminalnode = RegexASTNode(:terminal)
				terminalnode.args[:value] = string(chr)
				push!(andnode.children, terminalnode)

			end

			escaped = false

		end

		if rootexpr && (pos > sizeof(regex))
			endofexpr = true
		end

	end
	
	finishandnode(andnode)

	ornode, pos

end

# at end of an 'and' node in the AST
function finishandnode(andnode::RegexASTNode)
	
	if isempty(andnode.children)

		# special case of empty expression: we intepret this as any string of any characters from the tokenspace
		# for XML Schema, this is used for xs:string datatype
		# it differs from the regex ".*" in that all characters (including newlines) may be included

		bracketnode = RegexASTNode(:bracket)
    bracketnode.func = :bracket

    for range in [9:10; 13:13; 32:126] # currently just ASCII
      rangenode = RegexASTNode(:range)
      rangenode.args[:value] = range
      push!(bracketnode.children, rangenode)
		end
		
		quantifiernode = RegexASTNode(:quantifier)
		quantifiernode.args[:lowerbound] = 0
		quantifiernode.args[:upperbound] = typemax(Int)
		push!(quantifiernode.children, bracketnode)

		push!(andnode.children, quantifiernode)

	end
	
end

# parse integer value in the regex starting at pos
function regexparseint(regex::AbstractString, pos)

	startpos = pos
	while (pos<=sizeof(regex)) && isdigit(regex[pos])
		pos = nextind(regex, pos)
	end

	if pos > sizeof(regex)
		error("end of regex reached before parsing integer in regex qualifier")
	end

	endpos = prevind(regex, pos)
	if startpos > endpos
			error("empty string when parsing integer in regex qualifier")
	end

	parse(Int,regex[startpos:endpos]), pos

end

# parse a bracket expression in the regex
function regexparsebracket(regex::AbstractString, pos)

	bracketnode = RegexASTNode(:bracket)

	firstchar = true
	endofexpr = false

	while (!endofexpr)

		if pos > sizeof(regex)
			error("end of regex reached before parsing of bracket expression complete")
		end

		chr = regex[pos]
		pos = nextind(regex, pos)

		if (chr=='^') && (firstchar)

       process_error("cannot process negated bracket expressions")

		elseif (chr==']') && (!firstchar)

			endofexpr = true

		else

			if (nextind(regex,pos)<=sizeof(regex)) && (regex[pos]=='-') && (regex[nextind(regex,pos)]!=']')

				rangestart = convert(Int,chr)
				pos = nextind(regex,pos)
				rangeend = convert(Int,regex[pos])
				if rangeend < rangestart
					error("end of range in bracket expression is before the start of the range in $(regex)")
				end
				pos = nextind(regex,pos)

			else

				rangestart = convert(Int,chr)
				rangeend = rangestart

			end

			rangenode = RegexASTNode(:range)
			rangenode.args[:value] = rangestart:rangeend
			push!(bracketnode.children, rangenode)

		end

		firstchar = false

	end

	bracketnode, pos

end

# build set of methods to implement generator for regex
function regexconstructmethods(node::RegexASTNode, gencontext)

	methods = (Expr)[]
	
	if node.func in [:range]
		
		# nodes do not have an associated rule - do nothing
		
	else
	
		if node.func in [:or]
		
			if length(node.children) == 1
				body = Expr(:call, node.children[1].methodname, gencontext.genparam, gencontext.stateparam)
			else
				cpidvar = gensym("cpid")
				res = Expr(:call, node.children[1].methodname, gencontext.genparam, gencontext.stateparam)
				numdefs = length(node.children)
				for i in 2:numdefs
					calli = Expr(:call, node.children[i].methodname, gencontext.genparam, gencontext.stateparam)
					res = :( ($(cpidvar) == $i) ? ($calli) : ($res) )
				end
				cpid = recordchoicepoint(gencontext, RULE_CP, Dict{Symbol, Any}(:rulename=>node.methodname, :min=>1, :max=>numdefs))
				body = Expr(:block, :($(cpidvar) = $(THIS_MODULE).chooserule($(gencontext.stateparam), $cpid, $numdefs)), res)
			end
		
	 	elseif node.func in [:and]
	 
			if length(node.children) == 1
				body = Expr(:call, node.children[1].methodname, gencontext.genparam, gencontext.stateparam)
			else
				calls = map(child -> Expr(:call, child.methodname, gencontext.genparam, gencontext.stateparam), node.children)
				body = Expr(:call, :(*), calls...)
			end
		
		elseif node.func in [:terminal]

			body = node.args[:value]

		elseif node.func in [:optional]

			res = Expr(:call, node.children[1].methodname, gencontext.genparam, gencontext.stateparam)
			cpid = recordchoicepoint(gencontext, VALUE_CP, Dict{Symbol, Any}(:datatype=>Bool, :min=>false, :max=>true))
			body = :( $(THIS_MODULE).choosenumber($(gencontext.stateparam), $cpid, Bool, 0, 1, true) ? $res : "" )
			
		elseif node.func in [:quantifier]
		
			stmts = (Expr)[]

	    cpmin = node.args[:lowerbound]
	    cpmax = node.args[:upperbound]

			if (cpmax == Inf) || (cpmin < cpmax)
					if (cpmax == Inf)
						cpmax = typemax(Int)
					end
					functocallexpr = Expr(:call, node.children[1].methodname, gencontext.genparam, gencontext.stateparam)
					cpid = recordchoicepoint(gencontext, SEQUENCE_CP, Dict{Symbol, Any}(:min=>cpmin, :max=>cpmax))
					# upperboundexpr = Expr(:call, :choosereps, gencontext.stateparam, cpid, cpmin, cpmax, true)
					upperboundexpr = :( $(THIS_MODULE).choosereps($(gencontext.stateparam), $(cpid), $(cpmin), $(cpmax), true) )
	    else
					functocallexpr = :( $(node.children[1].methodname)($(gencontext.genparam), $(gencontext.stateparam)) )
					upperboundexpr = :( $(cpmax) )
	    end

			stmt = :( join( [ $(functocallexpr) for i in 1:$(upperboundexpr) ] ) )
			push!(stmts, stmt)				

			body = Expr(:block, stmts...)

		elseif node.func in [:bracket]

	    cardinality = 0
	    for child in node.children
	      range = child.args[:value]
	      cardinality += length(range)
	    end

			if cardinality == 0
				body = ""
		  else
			
				stmts = (Expr)[]
			
				idxvar = gensym("idx")

				cpid = recordchoicepoint(gencontext, VALUE_CP, Dict{Symbol, Any}(:datatype=>Int, :min=>0, :max=>cardinality-1))
				stmt = :( $(idxvar) = $(THIS_MODULE).choosenumber($(gencontext.stateparam), $cpid, Int, 0, $(cardinality-1), true) )
				push!(stmts, stmt)

				range = node.children[1].args[:value]
				res = :( $(range[1]) + $(idxvar) )
				offset = length(range)
				for i in 2:length(node.children)
					range = node.children[i].args[:value]
					resi = :( $(range[1]) + $(idxvar) - $offset )
					res = :( ($(idxvar) >= $offset) ? ($resi) : ($res) )
					offset += length(range)
				end
				stmt = :( string(convert(Char,$res)) )
				push!(stmts, stmt)

				body = Expr(:block, stmts...)
						
			end

		else
		
			@assert false
		
		end
		
		method = Expr(:(=), Expr(:call, node.methodname, gencontext.genarg, gencontext.statearg), body)			
		push!(methods, method)
			
	end

	for child in node.children
	  methods = [methods; regexconstructmethods(child, gencontext)]
	end
	
	methods

end


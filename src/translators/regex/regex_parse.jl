# parse regex into an AST
function parse_regex(regex::AbstractString, datatype::DataType)
	child, pos = parse_regex_expression(regex, datatype)
	ast = ASTNode(:regex, [child,], Dict{Symbol, Any}(:datatype=>datatype))
end

# parse an expression within the regex
function parse_regex_expression(regex::AbstractString, datatype::DataType, pos=1)

	rootexpr = (pos==1)
	ornode = ASTNode(:or)
	andnode = ASTNode(:and)
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

				finish_and_node(andnode, datatype)
				andnode = ASTNode(:and)
				push!(ornode.children, andnode)

			elseif (chr=='(') && (!escaped)

				exprnode, pos = parse_regex_expression(regex, datatype, pos)
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

				optionalnode = ASTNode(:optional)
				push!(optionalnode.children, precedingnode)
				
				push!(andnode.children, optionalnode)

			elseif (chr in ['+', '*', '{']) && (!escaped)

				if isempty(andnode.children)
					error("no preceding item to apply $(chr) to")
				end

				precedingnode = pop!(andnode.children)

				quantifiernode = ASTNode(:quantifier)
				push!(quantifiernode.children, precedingnode)

				if chr=='{'

					quantifiernode.args[:lowerbound], pos = parse_regex_int(regex::AbstractString, pos)
					if (pos<=sizeof(regex)) && (regex[pos]==',')
						pos = nextind(regex,pos)
						if pos<=sizeof(regex)
							if regex[pos]=='}'
								quantifiernode.args[:upperbound] = typemax(Int)
							else
								quantifiernode.args[:upperbound], pos = parse_regex_int(regex::AbstractString, pos)
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

				bracketnode, pos = parse_regex_bracket(regex, pos)
				push!(andnode.children, bracketnode)

			elseif ((chr in ['s', 'S', 'd', 'D', 'w', 'W', 'i', 'I', 'c', 'C']) && (escaped)) ||
							(chr in ['.'] && (!escaped))
				
				# TODO implicitly here, set of tokenspace is 9:10,13:13,32:126 - tab, new line, carriage return, plus printable ASCII
				# TODO to what extent should ASCII control characters be included? - here have tab (9), new line (10) and carriage return (13)
				# TODO strictly whitespace can include vertical tab (11) and form feed (13), but XML definition excludes them
				# TODO strictly wildcard (.) excludes just new line; but XML also excludes carriage return

				# TODO need to handle for non-ASCII datatypes

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
				if chr != '.'
					warn("cannot process character class $(node.args[:value]) - using wildcard instead")
				end
	        	classspace = (UnitRange)[9:9,32:126] # wildcard (.) - excludes new line and -- for XML -- carriage return
	      end

				bracketnode = ASTNode(:bracket)
	      bracketnode.func = :bracket

	      for range in classspace
	        rangenode = ASTNode(:range)
	        rangenode.args[:value] = range
	        push!(bracketnode.children, rangenode)
				end

				push!(andnode.children, bracketnode)
				
			elseif (chr in ['^','$'] && (!escaped))
				
				# ignore: ^ and $ have no meaning in generation context TODO?

			else

				terminalnode = ASTNode(:terminal)
				terminalnode.args[:value] = string(chr)
				push!(andnode.children, terminalnode)

			end

			escaped = false

		end

		if rootexpr && (pos > sizeof(regex))
			endofexpr = true
		end

	end
	
	finish_and_node(andnode, datatype)

	ornode, pos

end

# at end of an 'and' node in the AST
function finish_and_node(andnode::ASTNode, datatype::DataType)
	
	if isempty(andnode.children)

		# special case of empty expression: we intepret this as any string of any characters from the tokenspace
		# for XML Schema, this is used for xs:string datatype
		# it differs from the regex ".*" in that all characters (including newlines) may be included

		bracketnode = ASTNode(:bracket)
	    bracketnode.func = :bracket

		if datatype in [ASCIIString,]
        	classspace = (UnitRange)[9:10, 13:13, 32:126]
        elseif datatype in [UTF8String, UTF16String, UTF32String,]
			classspace = (UnitRange)[9:10, 13:13, 32:55295, 65536:131071, 131072:196607]  
			# 55295 (0xD7FF) is last character before UTF-16 surrogates in plane 0 (BMP)
			# 65536-131071 (0x10000 - 0x1FFFF) is plane 1 (SMP)
			# 131072-196607 (0x20000 - 0x2FFFF) is plane 2 (SIP)
		else
			error("Do not know how to handle empty regex for string datatype $(datatype)")
		end

	    for range in classspace # currently just ASCII
	      rangenode = ASTNode(:range)
	      rangenode.args[:value] = range
	      push!(bracketnode.children, rangenode)
		end
		
		quantifiernode = ASTNode(:quantifier)
		quantifiernode.args[:lowerbound] = 0
		quantifiernode.args[:upperbound] = typemax(Int)
		push!(quantifiernode.children, bracketnode)

		push!(andnode.children, quantifiernode)

	end
	
end

# parse integer value in the regex starting at pos
function parse_regex_int(regex::AbstractString, pos)

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
function parse_regex_bracket(regex::AbstractString, pos)

	bracketnode = ASTNode(:bracket)

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

			rangenode = ASTNode(:range)
			rangenode.args[:value] = rangestart:rangeend
			push!(bracketnode.children, rangenode)

		end

		firstchar = false

	end

	bracketnode, pos

end
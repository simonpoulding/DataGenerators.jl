using ParserCombinator

function parse_bnf(bnffilepath, syntax)
		
	# using a flexible grammar incorporating common variants of BNF and EBNF so as to avoid need for user to specify the variant
	
	# TODO for antlr4:
	# handling escape sequences in literals and some in regular expressions, e.g. // and /'
	# regular expressions which are not bracketed expressions
	# multi-line comments
	# directives (-->skip)	
	if !(syntax in [:ebnf, :antlr4])
		error("specify :ebnf or :antlr4 as the syntax")
	end
	
	# whitespace and comments
	whitespace = p"\s"
	if syntax == :antlr4
		comment = P"//.*$" | P"/\*.*\*/"
	else
		comment = P"\(\*.*\*\)" 
	end
	ws = Drop(Star(whitespace | comment))
	
	# variables
	identifier = p"\w+"
	# allow variable names with and without <...> delimiter:
	variablename = identifier | (E"<" + identifier + E">")
	# allow ::=, :, and = as symbol separating lhs and rhs of each rule
	definesymbol = E"::=" | E":" | E"="
	variabledef = variablename + ws + definesymbol								|> ns->ASTNode(:variabledef, ASTNode[], Dict{Symbol,Any}(:name=>ns[1]))
	variableref = variablename													|> ns->ASTNode(:variableref, ASTNode[], Dict{Symbol,Any}(:name=>ns[1]))
	
	# terminals
	# allow both "..." and '...' as delimiters for literals
	terminal = (E"'" + p"[^']*" + E"'") | (E"\"" + p"[^\"]*" + E"\"") 			|> ns->ASTNode(:literal, ASTNode[], Dict{Symbol,Any}(:value=>ns[1]))
	
	# regular expression (using [] syntax meaning optionality elsewhere) - we retain square brackets
	if syntax == :antlr4
		# todo - proper handling of escaped ] etc.
		regexp = p"\[.+\]"														|> ns->ASTNode(:regexp, ASTNode[], Dict{Symbol,Any}(:value=>ns[1]))
	end
	
	# symbols
	if syntax == :antlr4
		symbol = terminal |  regexp | variableref
	else
		symbol = terminal |  variableref
	end
		
	
	
	# bracketed expressions
	# (...) grouping
	# [...] optional
	# {...} repeat	
	expr = Delayed()
	groupexpr = E"(" + ws + expr + ws + E")"
	if syntax != :antlr4
		# for anltr, square brackets indiciate regular expressions, so omit this
		optionalexpr = E"[" + ws + expr + ws + E"]"								|> ns->ASTNode(:optional, convert(Array{ASTNode}, ns))
	end
	repeatexpr = E"{" + ws + expr + ws + E"}"									|> ns->ASTNode(:quantifier, convert(Array{ASTNode}, ns), Dict{Symbol,Any}(:min=>0))

	# operators
	# precedence (highest first)
	# ~ negation (Antlr)
	# * (repetition)
	# , (concatenate)
	# | (choice)
	if syntax == :antlr4
		negatableexpr = symbol | groupexpr		# TODO negation don't make sense for optional and repeat exprs? - in any case, these aren't used by ANTLR
		negexpr = E"~" + ws + negatableexpr										|> ns->ASTNode(:negation, convert(Array{ASTNode}, ns))
	end

	if syntax == :antlr4
		quantifiableexpr = symbol | groupexpr | negexpr		# TODO quantifiers don't make sense for optional and repeat exprs?
	else
		quantifiableexpr = symbol | groupexpr	# TODO quantifiers don't make sense for optional and repeat exprs?
	end
	quesexpr = quantifiableexpr + ws + E"?"										|> ns->ASTNode(:optional, convert(Array{ASTNode}, ns))
	starexpr = quantifiableexpr + ws + E"*"										|> ns->ASTNode(:quantifier, convert(Array{ASTNode}, ns), Dict{Symbol,Any}(:min=>0))
	plusexpr = quantifiableexpr + ws + E"+"										|> ns->ASTNode(:quantifier, convert(Array{ASTNode}, ns), Dict{Symbol,Any}(:min=>1))
	
	if syntax == :antlr4
		primaryexpr = symbol | groupexpr | repeatexpr | starexpr | plusexpr | quesexpr | negexpr
	else
		primaryexpr = symbol | groupexpr | optionalexpr | repeatexpr | starexpr | plusexpr | quesexpr
	end
	
	concatsymbol = E"," | P"\s+"
	concatexpr = Star(primaryexpr + ws + concatsymbol + ws) + primaryexpr		|> ns->ASTNode(:concatenation, convert(Array{ASTNode}, ns))
	
	altsymbol = E"|"
	altexpr = Star(concatexpr + ws + altsymbol + ws) + concatexpr				|> ns->ASTNode(:alternation, convert(Array{ASTNode}, ns))
	
	expr.matcher = altexpr
	
	# rules
	# allow ;, ., or end-of-line to terminate rule
	ruleterminatorsym = E";" | E"." | P"$" 
	rule = P"^" + ws + variabledef + ws + expr + ws + ruleterminatorsym			|> ns->begin ns[1].children=ASTNode[ns[2],]; ns[1] end
	
	# grammar
	grammar = ws + Star(rule + ws) + rule + ws 									|> ns->ASTNode(:bnf, convert(Array{ASTNode}, ns))
	
	
	
	astarray = open(bnffilepath, "r") do io
	  parse_try(io, Try(grammar + Eos()))
	  # note: Try not only enables (limited?) backtracking but also
	  # permits use of parse_try to process whole file (parse_one cannout be used
	  # in the same way in this particular idiom)
	end
	
	if isempty(astarray)
		error("No production rules found")
	end
	
	astarray[1]

end
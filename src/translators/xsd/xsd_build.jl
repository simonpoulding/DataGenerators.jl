function build_xsd_generator(io::IO, ast::ASTNode, genname, startelement)
	
	assign_methodnames(ast)
	ast.methodname = "start"

	println(io, "using LightXML")			# LightXML specific

	build_generator_start(io, genname, "XML with $(startelement) element as the root")
	build_xsd_lightxml_specific(io)	
	build_xsd_methods(io, ast)
	build_generator_end(io)

end

function build_xsd_methods(io::IO, node::ASTNode)

  if node.func in [:xsd]
    build_xsd_xsd(io, node)
  elseif node.func in [:element]
    build_xsd_element(io, node)
  elseif node.func in [:attribute]
    build_xsd_attribute(io, node)
  elseif node.func in [:group, :attributeGroup, :complexType, :sequence, :extension]
    build_xsd_sequence(io, node)
  elseif node.func in [:simpleType, :simpleContent, :complexContent, :restriction]
    build_xsd_call(io, node)
  elseif node.func in [:pattern]
  build_xsd_pattern(io, node)
  elseif node.func in [:choice, :substitutionGroup, :union]
    build_xsd_choice(io, node)
  elseif node.func in [:quantifier]
    build_xsd_quantifier(io, node)
  elseif node.func in [:optional]
    build_xsd_optional(io, node)
  elseif node.func in [:enumeration]
    build_xsd_enumeration(io, node)
  elseif node.func in [:list]
    build_xsd_list(io, node)
  elseif node.func in [:any, :anyAttribute, :nothing]
    build_xsd_nothing(io, node)
  elseif node.func in [:elementRef, :elementSub, :typeRef, :attributeRef, :groupRef, :attributeGroupRef]
    # do nothing
    @assert isempty(node.children)
  else
    error("Unexpected xml node function $(node.func)")
  end

  for child in node.children
    build_xsd_methods(io, child)
  end

end

# # isolates code that is specific to the XML package used to build the XML
function build_xsd_lightxml_specific(io)
	# println(io, "construct_element(name::AbstractString, content::Array{Any}) = begin")
	# TODO for the moment, remove typing on arguments to rule since this breaks under Julia 4.0
	println(io, "construct_element(name, content) = begin")
	println(io, "  xmlelement = new_element(name)")
	println(io, "  for item in content")
	println(io, "    if typeof(item) <: Tuple{AbstractString,Array}")
	# 	println(io, "    if typeof(item) <: Main.XMLElement")			# LightXML specific # TODO remove explicit Main. when GT support this properly
	# 	println(io, "      add_child(xmlelement, item)")			# LightXML specific
	println(io, "      add_child(xmlelement, construct_element(item[1], item[2]))")			# LightXML specific
	println(io, "    elseif typeof(item) <: Tuple{AbstractString,AbstractString}")
	println(io, "      set_attribute(xmlelement, item[1], item[2])")			# LightXML specific
	println(io, "    elseif typeof(item) <: AbstractString")
	println(io, "      add_text(xmlelement, item)")			# LightXML specific
	println(io, "    else")
	println(io, "      @assert false")
	println(io, "    end")
	println(io, "  end")
	println(io, "  xmlelement")
	println(io, "end")
end


function build_xsd_xsd(io::IO, node::ASTNode)
  build_method_start(io, node)
  @assert length(node.refs)==1
  methodname = build_called_methodname(node)
  println(io, "  name, content = $(methodname)")
  println(io, "  construct_element(name, content)")
  build_method_end(io, node)
end

function build_xsd_element(io::IO, node::ASTNode)
  build_method_start(io, node)
  build_xsd_sequence_body(io, node)
	println(io, "  (\"$(escape_str(node.args[:name]))\", content)")
	# println(io, "  construct_element(\"$(escape_str(node.args[:name]))\", content)")
	# ... appear to need Main to be explicit when construct_element is defined outside of generator
  build_method_end(io, node)
end


function build_xsd_attribute(io::IO, node::ASTNode)
  build_method_start(io, node)
  @assert length(node.children)==1
  methodname = build_called_methodname(node.children[1])
  println(io, "  content = $(methodname)")
  println(io, "  @assert typeof(content)<:AbstractString")
  println(io, "  (\"$(escape_str(node.args[:name]))\", content)")
  build_method_end(io, node)
end


function build_xsd_sequence(io::IO, node::ASTNode)
  build_method_start(io, node)
  build_xsd_sequence_body(io, node)
  println(io, "  content")
  build_method_end(io, node)
end

function build_xsd_call(io::IO, node::ASTNode)
  build_method_start(io, node)
  @assert length(node.children)==1
  methodname = build_called_methodname(node.children[1])
  println(io, "  $(methodname)")
  build_method_end(io, node)
end

function build_xsd_pattern(io::IO, node::ASTNode)
  build_method_start(io, node)
  println(io, "  choose(UTF8String, \"$(escape_str(node.args[:value]))\")")
  build_method_end(io, node)
end

function build_xsd_choice(io::IO, node::ASTNode)
  if isempty(node.children)
	  build_method_start(io, node)
    println(io, "  (Any)[]")
	  build_method_end(io, node)
  else
    for child in node.children
		  build_method_start(io, node)
	    methodname = build_called_methodname(child)
	    println(io, "  $(methodname)")
		  build_method_end(io, node)
		end
  end
end

function build_xsd_quantifier(io::IO, node::ASTNode)
  build_method_start(io, node)
  @assert haskey(node.args, :lowerbound)
  @assert haskey(node.args, :upperbound)
  @assert length(node.children)==1
  lowerbound = node.args[:lowerbound]
  upperbound = node.args[:upperbound]
  methodname = build_called_methodname(node.children[1])
	if (upperbound == Inf) || (lowerbound < upperbound)
		if (upperbound == Inf)
			println(io, "  r = reps($(methodname), $(lowerbound))")
		else
			println(io, "  r = reps($(methodname), $(lowerbound), $(upperbound))")
		end
	else
		println(io, "  r = [$(methodname)() for i in 1:$(lowerbound)]")
	end
  println(io, "  reduce((v,e)->[v; e], Any[], r)") # note: this flattens arrays in childcontent in a way that convert would not do
  build_method_end(io, node)
end


function build_xsd_optional(io::IO, node::ASTNode)
  build_method_start(io, node)
  @assert length(node.children)==1
  methodname = build_called_methodname(node.children[1])
  println(io, "  choose(Bool) ? $(methodname) : Any[]")
  build_method_end(io, node)
end

function build_xsd_enumeration(io::IO, node::ASTNode)
  build_method_start(io, node)
  @assert haskey(node.args, :value)
  println(io, "  \"$(escape_str(node.args[:value]))\"")
  build_method_end(io, node)
end

function build_xsd_list(io::IO, node::ASTNode)
  build_method_start(io, node)
  @assert length(node.children)==1
  methodname = build_called_methodname(node.children[1])
  println(io, "  content = plus($(methodname))")
  println(io, "  join(content, \" \")")
  build_method_end(io, node)
end

function build_xsd_nothing(io::IO, node::ASTNode)
  build_method_start(io, node)
  println(io, "  (Any)[]")
  build_method_end(io, node)
end

function build_xsd_sequence_body(io::IO, parentnode::ASTNode)
  println(io, "  content = (Any)[]")
  for node in parentnode.children
    methodname = build_called_methodname(node)
    if node.func in [:elementSub]
      println(io, "  childelement = $(methodname)")
      println(io, "  childcontent = childelement[2]")
    else
      println(io, "  childcontent = $(methodname)")
    end
    println(io, "  content = [content; childcontent]")  # note: this flattens arrays in childcontent in a way that push! would not do
  end
end

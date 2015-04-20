require("../src/GodelTest.jl")
using GodelTest
using BlackBoxOptim

#
# Generator automatically created by GodelTestAutoTest.jl from XSD at http://examples.oreilly.com/9780596002527/, Chapter 3, Sample 3 
# Manual changes: commented out warnings; changed choose(UTF8,...) to choose(ASCIIString,...) also to avoid warnings 
#
using LightXML
@generator XSDGen begin
  generates: ["XML with library element as the root"]
construct_element(name::String, content::Array{Any}) = begin
  xmlelement = new_element(name)
  for item in content
    if typeof(item) <: Main.XMLElement
      add_child(xmlelement, item)
    elseif typeof(item) <: (String,String)
      set_attribute(xmlelement, item[1], item[2])
    elseif typeof(item) <: String
      add_text(xmlelement, item)
    else
      @assert false
    end
  end
  xmlelement
end
start = begin
  xsd_1_element_library
end
# <element name="library"/>
xsd_1_element_library = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType
  content = [content, childcontent]
  construct_element("library", content)
end
# <complexType/>
xsd_1_element_library_1_complexType = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_1_element_library_1_complexType_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier
  content = [content, childcontent]
  content
end
# <element name="book" maxOccurs="unbounded"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier = begin
  r = reps(xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book, 1)
  reduce((v,e)->[v,e], Any[], r)
end
# <element name="book" maxOccurs="unbounded"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType
  content = [content, childcontent]
  construct_element("book", content)
end
# <complexType/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_2_optional
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_3_optional
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_1_element_isbn
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier
  content = [content, childcontent]
  content
end
# <element name="isbn" type="xs:integer"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_1_element_isbn = begin
  content = (Any)[]
  childcontent = xsd_2_simpleType_xs_integer
  content = [content, childcontent]
  construct_element("isbn", content)
end
# <element name="title"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType
  content = [content, childcontent]
  construct_element("title", content)
end
# <complexType/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent
  content = [content, childcontent]
  content
end
# <simpleContent/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent = begin
  xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent_1_extension
end
# <extension base="xs:string"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent_1_extension = begin
  content = (Any)[]
  childcontent = xsd_3_simpleType_xs_string
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent_1_extension_2_optional
  content = [content, childcontent]
  content
end
# <attribute name="lang" type="xs:language"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent_1_extension_2_optional = begin
  choose(Bool) ? xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent_1_extension_2_optional_1_attribute_lang : Any[]
end
# <attribute name="lang" type="xs:language"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_2_element_title_1_complexType_1_simpleContent_1_extension_2_optional_1_attribute_lang = begin
  content = xsd_4_simpleType_xs_language
  @assert typeof(content)<:String
  ("lang", content)
end
# <element name="author" minOccurs="0" maxOccurs="unbounded"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier = begin
  r = reps(xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author, 0)
  reduce((v,e)->[v,e], Any[], r)
end
# <element name="author" minOccurs="0" maxOccurs="unbounded"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType
  content = [content, childcontent]
  construct_element("author", content)
end
# <complexType/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_2_optional
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence_1_element_name
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence_2_element_born
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence_3_element_dead
  content = [content, childcontent]
  content
end
# <element name="name" type="xs:string"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence_1_element_name = begin
  content = (Any)[]
  childcontent = xsd_3_simpleType_xs_string
  content = [content, childcontent]
  construct_element("name", content)
end
# <element name="born" type="xs:date"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence_2_element_born = begin
  content = (Any)[]
  childcontent = xsd_5_simpleType_xs_date
  content = [content, childcontent]
  construct_element("born", content)
end
# <element name="dead" type="xs:date"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_1_sequence_3_element_dead = begin
  content = (Any)[]
  childcontent = xsd_5_simpleType_xs_date
  content = [content, childcontent]
  construct_element("dead", content)
end
# <attribute name="id" type="xs:ID"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_2_optional = begin
  choose(Bool) ? xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_2_optional_1_attribute_id : Any[]
end
# <attribute name="id" type="xs:ID"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_3_quantifier_1_element_author_1_complexType_2_optional_1_attribute_id = begin
  content = xsd_6_simpleType_xs_ID
  @assert typeof(content)<:String
  ("id", content)
end
# <element name="character" minOccurs="0" maxOccurs="unbounded"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier = begin
  r = reps(xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character, 0)
  reduce((v,e)->[v,e], Any[], r)
end
# <element name="character" minOccurs="0" maxOccurs="unbounded"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType
  content = [content, childcontent]
  construct_element("character", content)
end
# <complexType/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_2_optional
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence_1_element_name
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence_2_element_born
  content = [content, childcontent]
  childcontent = xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence_3_element_qualification
  content = [content, childcontent]
  content
end
# <element name="name" type="xs:string"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence_1_element_name = begin
  content = (Any)[]
  childcontent = xsd_3_simpleType_xs_string
  content = [content, childcontent]
  construct_element("name", content)
end
# <element name="born" type="xs:date"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence_2_element_born = begin
  content = (Any)[]
  childcontent = xsd_5_simpleType_xs_date
  content = [content, childcontent]
  construct_element("born", content)
end
# <element name="qualification" type="xs:string"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_1_sequence_3_element_qualification = begin
  content = (Any)[]
  childcontent = xsd_3_simpleType_xs_string
  content = [content, childcontent]
  construct_element("qualification", content)
end
# <attribute name="id" type="xs:ID"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_2_optional = begin
  choose(Bool) ? xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_2_optional_1_attribute_id : Any[]
end
# <attribute name="id" type="xs:ID"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_1_sequence_4_quantifier_1_element_character_1_complexType_2_optional_1_attribute_id = begin
  content = xsd_6_simpleType_xs_ID
  @assert typeof(content)<:String
  ("id", content)
end
# <attribute name="id" type="xs:ID"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_2_optional = begin
  choose(Bool) ? xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_2_optional_1_attribute_id : Any[]
end
# <attribute name="id" type="xs:ID"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_2_optional_1_attribute_id = begin
  content = xsd_6_simpleType_xs_ID
  @assert typeof(content)<:String
  ("id", content)
end
# <attribute name="available" type="xs:boolean"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_3_optional = begin
  choose(Bool) ? xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_3_optional_1_attribute_available : Any[]
end
# <attribute name="available" type="xs:boolean"/>
xsd_1_element_library_1_complexType_1_sequence_1_quantifier_1_element_book_1_complexType_3_optional_1_attribute_available = begin
  content = xsd_7_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("available", content)
end
xsd_2_simpleType_xs_integer = begin
  xsd_2_simpleType_xs_integer_1_pattern
end
xsd_2_simpleType_xs_integer_1_pattern = begin
  choose(ASCIIString, "[+-]?[0-9]+")
end
xsd_3_simpleType_xs_string = begin
  xsd_3_simpleType_xs_string_1_pattern
end
xsd_3_simpleType_xs_string_1_pattern = begin
  choose(ASCIIString, "")
end
xsd_4_simpleType_xs_language = begin
  # warn("Do not know how to generate built-in type xs:language - reverting to xs:string in xsd_4_simpleType_xs_language")
  xsd_4_simpleType_xs_language_1_pattern
end
xsd_4_simpleType_xs_language_1_pattern = begin
  choose(ASCIIString, "")
end
xsd_5_simpleType_xs_date = begin
  xsd_5_simpleType_xs_date_1_pattern
end
xsd_5_simpleType_xs_date_1_pattern = begin
  choose(ASCIIString, "[+-]?([0-9]{4}-((01|03|05|07|08|10|12)-(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)-(0[1-9]|[1-2][0-9]|30)|02-(0[1-9]|1[0-9]|2[0-8]))|[0-9]{2}((1|3|5|7|9)(2|6)|(2|4|6|8)(0|4|8)|0(4|8))-02-29|((0|2|4|8)(0|4|8)|(1|3|5|7)(2|6))00-02-29)(Z|[+-](0[0-9]|1[0-4]):[0-5][0-9])?")
end
xsd_6_simpleType_xs_ID = begin
  # warn("uniqueness of xs:ID not enforced in xsd_6_simpleType_xs_ID")
  xsd_6_simpleType_xs_ID_1_pattern
end
xsd_6_simpleType_xs_ID_1_pattern = begin
  choose(ASCIIString, "\\i\\c*")
end
xsd_7_simpleType_xs_boolean = begin
  xsd_7_simpleType_xs_boolean_1_pattern
end
xsd_7_simpleType_xs_boolean_1_pattern = begin
  choose(ASCIIString, "true|false")
end
end
#
# End of automatically created generator
#


# count the number of elements, attributes, and text nodes in an XML fragment
function analysexmlelement(xelement)
	elementcount = 1
	attributecount = length(attributes_dict(xelement))
	textnodecount = 0
	for xchildnode in child_nodes(xelement)
		if is_textnode(xchildnode)
			if length(strip(string(xchildnode))) > 0
				textnodecount += 1
			end
		end
	end
	for xchildelement in child_elements(xelement)
		childelementcount, childattributecount, childtextnodecount = analysexmlelement(xchildelement)
		elementcount += childelementcount
		attributecount += childattributecount
		textnodecount += childtextnodecount
	end
	elementcount, attributecount, textnodecount
end 

const TargetElementCount = 10
const TargetAttributeCount = 5
const TargetTextNodeCount = 10

# distance from target counts of elements, attributes, and text nodes
function countdistance(xml)	
	elementcount, attributecount, textnodecount = analysexmlelement(xml)
	sqrt((elementcount-TargetElementCount)^2 + (attributecount-TargetAttributeCount)^2 + (textnodecount-TargetTextNodeCount)^2)
end

# handles distance when string is nothing
robustcountdistance(xml) = xml==nothing ? 1000 : countdistance(xml)

# create a generator instance
gn = XSDGen()

# create a choice model using the sampler choice model
cm = SamplerChoiceModel(gn)

# Number of expressions sampled when comparing different choice models
NumSamples = 30

# Limit on the number of choices made per generation
MaxChoices = 10000

# Generate examples from unoptimized model
unoptimized_examples = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumSamples]

# Number of generated data items per fitness calculation
NumDataPerFitnessCalc = 20

# define a fitness function (here as a closure)
# argument is a vector of model parameters
function fitnessfn(modelparams)
	# sets parameters of choice model
	setparams(cm, vec(modelparams))  
	# get a sample of data items from the generator using this choice model
	xmls = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumDataPerFitnessCalc]
	# gencatch returns nothing if generator terminated owing the maxchoices being exceeded
	mean(map(xml->robustcountdistance(xml), xmls))
end

# optimise the choice model params with BlackBoxOptim
# paramranges returns a vector of tuples that specify the valid ranges of the model parameters
# bboptimize is from the BlackBoxOptim package
optimresult = bboptimize(fitnessfn; search_range = paramranges(cm), max_time = 30.0)
bestmodelparams = optimresult[1]

# apply the best parameters found
setparams(cm, vec(bestmodelparams))

# generate data using the optimised model
optimized_examples = [robustgen(gn, choicemodel=cm, maxchoices=MaxChoices) for i in 1:NumSamples]

# Print examples so they can be compared
report(examples, desc) = begin
  mean_dist = mean(map(robustcountdistance, examples))
  println("\n", desc, " examples (avg. distance from target = $mean_dist):\n  ", 
    examples[1:min(10, length(examples))])
end
report(unoptimized_examples, "Unoptimized")
report(optimized_examples, "Optimized (with BlackBoxOptim)")
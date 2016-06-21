require("../src/DataGenerators.jl")
using DataGenerators
using BlackBoxOptim

#
# Generator automatically created by DataGeneratorsAutoTest.jl from W3C XSD for MathML v2 (presentation only) with some minor corrections to the definition by Simon Poulding
# Manual changes: commented out warnings; changed choose(UTF8,...) to choose(ASCIIString,...) also to avoid warnings 
#
using LightXML
@generator XSDGen begin
  generates: ["XML with math element as the root"]
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
# <xs:annotation>
#   <xs:documentation>
#   This is an XML Schema for MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is an XML Schema module defining the "math" element of MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is the common attributes module for MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is an XML Schema module containing some type definitions for MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This schema module defines sets of attributes common to several elements
#   of presentation MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is the XML Schema module for the MathML "mglyph" element.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is the XML schema module for the token elements of the 
#   presentation part of MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is an XML Schema module for the presentation elements of MathML
#   dealing with subscripts and superscripts.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is the XML Schema module for the MathML "mspace" element.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is the XML schema module for the layout elements of the 
#   presentation part of MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is an XML Schema module for tables in MathML presentation.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is an XML Schema for the "mstyle" element of MathML.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is the XML Schema module for the MathML "merror" element.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
# <xs:annotation>
#   <xs:documentation>
#   This is the XML Schema module for the MathML "maction" element.
#   Author: Stéphane Dalmas, INRIA.
#   </xs:documentation>
# </xs:annotation>
start = begin
  xsd_6_element_math
end
# <group name="Presentation-expr.class"/>
xsd_1_group_Presentation_expr_class = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_1_group_Presentation_expr_class_1_choice = begin
  xsd_2_group_PresExpr_class
end
# <group name="PresExpr.class"/>
xsd_2_group_PresExpr_class = begin
  content = (Any)[]
  childcontent = xsd_2_group_PresExpr_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_2_group_PresExpr_class_1_choice = begin
  xsd_38_group_Presentation_token_class
end
# <choice/>
xsd_2_group_PresExpr_class_1_choice = begin
  xsd_96_group_Presentation_layout_class
end
# <choice/>
xsd_2_group_PresExpr_class_1_choice = begin
  xsd_66_group_Presentation_script_class
end
# <choice/>
xsd_2_group_PresExpr_class_1_choice = begin
  xsd_122_group_Presentation_table_class
end
# <choice/>
xsd_2_group_PresExpr_class_1_choice = begin
  xsd_69_element_mspace
end
# <choice/>
xsd_2_group_PresExpr_class_1_choice = begin
  xsd_130_element_maction
end
# <choice/>
xsd_2_group_PresExpr_class_1_choice = begin
  xsd_126_element_mstyle
end
# <attributeGroup name="math.attlist"/>
xsd_3_attributeGroup_math_attlist = begin
  content = (Any)[]
  childcontent = xsd_3_attributeGroup_math_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_3_attributeGroup_math_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="mode" type="xs:string"/>
xsd_3_attributeGroup_math_attlist_1_optional = begin
  choose(Bool) ? xsd_3_attributeGroup_math_attlist_1_optional_1_attribute_mode : Any[]
end
# <attribute name="mode" type="xs:string"/>
xsd_3_attributeGroup_math_attlist_1_optional_1_attribute_mode = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("mode", content)
end
# <attribute name="display" default="inline"/>
xsd_3_attributeGroup_math_attlist_2_optional = begin
  choose(Bool) ? xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display : Any[]
end
# <attribute name="display" default="inline"/>
xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display = begin
  content = xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType
  @assert typeof(content)<:String
  ("display", content)
end
# <simpleType/>
xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType = begin
  xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction = begin
  xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction_1_choice
end
xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction_1_choice = begin
  xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction_1_choice = begin
  xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction_1_choice_2_enumeration
end
# <enumeration value="block"/>
xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "block"
end
# <enumeration value="inline"/>
xsd_3_attributeGroup_math_attlist_2_optional_1_attribute_display_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "inline"
end
# <group name="math.content"/>
xsd_4_group_math_content = begin
  content = (Any)[]
  childcontent = xsd_4_group_math_content_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_4_group_math_content_1_choice = begin
  xsd_2_group_PresExpr_class
end
# <complexType name="math.type"/>
xsd_5_complexType_math_type = begin
  content = (Any)[]
  childcontent = xsd_4_group_math_content
  content = [content, childcontent]
  childcontent = xsd_3_attributeGroup_math_attlist
  content = [content, childcontent]
  content
end
# <element name="math" type="math.type"/>
xsd_6_element_math = begin
  content = (Any)[]
  childcontent = xsd_5_complexType_math_type
  content = [content, childcontent]
  construct_element("math", content)
end
# <attributeGroup name="Common.attrib"/>
xsd_7_attributeGroup_Common_attrib = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib_2_optional
  content = [content, childcontent]
  content
end
# <attribute name="class" type="xs:NMTOKENS"/>
xsd_7_attributeGroup_Common_attrib_1_optional = begin
  choose(Bool) ? xsd_7_attributeGroup_Common_attrib_1_optional_1_attribute_class : Any[]
end
# <attribute name="class" type="xs:NMTOKENS"/>
xsd_7_attributeGroup_Common_attrib_1_optional_1_attribute_class = begin
  content = xsd_132_simpleType_xs_NMTOKENS
  @assert typeof(content)<:String
  ("class", content)
end
# <attribute name="id" type="xs:ID"/>
xsd_7_attributeGroup_Common_attrib_2_optional = begin
  choose(Bool) ? xsd_7_attributeGroup_Common_attrib_2_optional_1_attribute_id : Any[]
end
# <attribute name="id" type="xs:ID"/>
xsd_7_attributeGroup_Common_attrib_2_optional_1_attribute_id = begin
  content = xsd_133_simpleType_xs_ID
  @assert typeof(content)<:String
  ("id", content)
end
# <simpleType name="simple-size"/>
xsd_8_simpleType_simple_size = begin
  xsd_8_simpleType_simple_size_1_restriction
end
# <restriction base="xs:string"/>
xsd_8_simpleType_simple_size_1_restriction = begin
  xsd_8_simpleType_simple_size_1_restriction_1_choice
end
xsd_8_simpleType_simple_size_1_restriction_1_choice = begin
  xsd_8_simpleType_simple_size_1_restriction_1_choice_1_enumeration
end
xsd_8_simpleType_simple_size_1_restriction_1_choice = begin
  xsd_8_simpleType_simple_size_1_restriction_1_choice_2_enumeration
end
xsd_8_simpleType_simple_size_1_restriction_1_choice = begin
  xsd_8_simpleType_simple_size_1_restriction_1_choice_3_enumeration
end
# <enumeration value="small"/>
xsd_8_simpleType_simple_size_1_restriction_1_choice_1_enumeration = begin
  "small"
end
# <enumeration value="normal"/>
xsd_8_simpleType_simple_size_1_restriction_1_choice_2_enumeration = begin
  "normal"
end
# <enumeration value="big"/>
xsd_8_simpleType_simple_size_1_restriction_1_choice_3_enumeration = begin
  "big"
end
# <simpleType name="named-space"/>
xsd_9_simpleType_named_space = begin
  xsd_9_simpleType_named_space_1_restriction
end
# <restriction base="xs:string"/>
xsd_9_simpleType_named_space_1_restriction = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice
end
xsd_9_simpleType_named_space_1_restriction_1_choice = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice_1_enumeration
end
xsd_9_simpleType_named_space_1_restriction_1_choice = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice_2_enumeration
end
xsd_9_simpleType_named_space_1_restriction_1_choice = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice_3_enumeration
end
xsd_9_simpleType_named_space_1_restriction_1_choice = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice_4_enumeration
end
xsd_9_simpleType_named_space_1_restriction_1_choice = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice_5_enumeration
end
xsd_9_simpleType_named_space_1_restriction_1_choice = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice_6_enumeration
end
xsd_9_simpleType_named_space_1_restriction_1_choice = begin
  xsd_9_simpleType_named_space_1_restriction_1_choice_7_enumeration
end
# <enumeration value="veryverythinmathspace"/>
xsd_9_simpleType_named_space_1_restriction_1_choice_1_enumeration = begin
  "veryverythinmathspace"
end
# <enumeration value="verythinmathspace"/>
xsd_9_simpleType_named_space_1_restriction_1_choice_2_enumeration = begin
  "verythinmathspace"
end
# <enumeration value="thinmathspace"/>
xsd_9_simpleType_named_space_1_restriction_1_choice_3_enumeration = begin
  "thinmathspace"
end
# <enumeration value="mediummathspace"/>
xsd_9_simpleType_named_space_1_restriction_1_choice_4_enumeration = begin
  "mediummathspace"
end
# <enumeration value="thickmathspace"/>
xsd_9_simpleType_named_space_1_restriction_1_choice_5_enumeration = begin
  "thickmathspace"
end
# <enumeration value="verythickmathspace"/>
xsd_9_simpleType_named_space_1_restriction_1_choice_6_enumeration = begin
  "verythickmathspace"
end
# <enumeration value="veryverythickmathspace"/>
xsd_9_simpleType_named_space_1_restriction_1_choice_7_enumeration = begin
  "veryverythickmathspace"
end
# <simpleType name="thickness"/>
xsd_10_simpleType_thickness = begin
  xsd_10_simpleType_thickness_1_restriction
end
# <restriction base="xs:string"/>
xsd_10_simpleType_thickness_1_restriction = begin
  xsd_10_simpleType_thickness_1_restriction_1_choice
end
xsd_10_simpleType_thickness_1_restriction_1_choice = begin
  xsd_10_simpleType_thickness_1_restriction_1_choice_1_enumeration
end
xsd_10_simpleType_thickness_1_restriction_1_choice = begin
  xsd_10_simpleType_thickness_1_restriction_1_choice_2_enumeration
end
xsd_10_simpleType_thickness_1_restriction_1_choice = begin
  xsd_10_simpleType_thickness_1_restriction_1_choice_3_enumeration
end
# <enumeration value="thin"/>
xsd_10_simpleType_thickness_1_restriction_1_choice_1_enumeration = begin
  "thin"
end
# <enumeration value="medium"/>
xsd_10_simpleType_thickness_1_restriction_1_choice_2_enumeration = begin
  "medium"
end
# <enumeration value="thick"/>
xsd_10_simpleType_thickness_1_restriction_1_choice_3_enumeration = begin
  "thick"
end
# <simpleType name="length-with-unit"/>
xsd_11_simpleType_length_with_unit = begin
  xsd_11_simpleType_length_with_unit_1_restriction
end
# <restriction base="xs:string"/>
xsd_11_simpleType_length_with_unit_1_restriction = begin
  xsd_11_simpleType_length_with_unit_1_restriction_1_choice
end
xsd_11_simpleType_length_with_unit_1_restriction_1_choice = begin
  xsd_11_simpleType_length_with_unit_1_restriction_1_choice_1_pattern
end
# <pattern value="(-?([0-9]+|[0-9]*\.[0-9]+) *(em|ex|px|in|cm|mm|pt|pc|%))|0"/>
xsd_11_simpleType_length_with_unit_1_restriction_1_choice_1_pattern = begin
  choose(ASCIIString, "(-?([0-9]+|[0-9]*\\.[0-9]+) *(em|ex|px|in|cm|mm|pt|pc|%))|0")
end
# <simpleType name="length-with-optional-unit"/>
xsd_12_simpleType_length_with_optional_unit = begin
  xsd_12_simpleType_length_with_optional_unit_1_restriction
end
# <restriction base="xs:string"/>
xsd_12_simpleType_length_with_optional_unit_1_restriction = begin
  xsd_12_simpleType_length_with_optional_unit_1_restriction_1_choice
end
xsd_12_simpleType_length_with_optional_unit_1_restriction_1_choice = begin
  xsd_12_simpleType_length_with_optional_unit_1_restriction_1_choice_1_pattern
end
# <pattern value="-?([0-9]+|[0-9]*\.[0-9]+) *(em|ex|px|in|cm|mm|pt|pc|%)?"/>
xsd_12_simpleType_length_with_optional_unit_1_restriction_1_choice_1_pattern = begin
  choose(ASCIIString, "-?([0-9]+|[0-9]*\\.[0-9]+) *(em|ex|px|in|cm|mm|pt|pc|%)?")
end
# <simpleType name="infinity"/>
xsd_13_simpleType_infinity = begin
  xsd_13_simpleType_infinity_1_restriction
end
# <restriction base="xs:string"/>
xsd_13_simpleType_infinity_1_restriction = begin
  xsd_13_simpleType_infinity_1_restriction_1_choice
end
xsd_13_simpleType_infinity_1_restriction_1_choice = begin
  xsd_13_simpleType_infinity_1_restriction_1_choice_1_enumeration
end
# <enumeration value="infinity"/>
xsd_13_simpleType_infinity_1_restriction_1_choice_1_enumeration = begin
  "infinity"
end
# <simpleType name="RGB-color"/>
xsd_14_simpleType_RGB_color = begin
  xsd_14_simpleType_RGB_color_1_restriction
end
# <restriction base="xs:string"/>
xsd_14_simpleType_RGB_color_1_restriction = begin
  xsd_14_simpleType_RGB_color_1_restriction_1_choice
end
xsd_14_simpleType_RGB_color_1_restriction_1_choice = begin
  xsd_14_simpleType_RGB_color_1_restriction_1_choice_1_pattern
end
# <pattern value="#(([0-9]|[a-f]){3}|([0-9]|[a-f]){6})"/>
xsd_14_simpleType_RGB_color_1_restriction_1_choice_1_pattern = begin
  choose(ASCIIString, "#(([0-9]|[a-f]){3}|([0-9]|[a-f]){6})")
end
# <attributeGroup name="Token-style.attrib"/>
xsd_15_attributeGroup_Token_style_attrib = begin
  content = (Any)[]
  childcontent = xsd_15_attributeGroup_Token_style_attrib_1_optional
  content = [content, childcontent]
  childcontent = xsd_15_attributeGroup_Token_style_attrib_2_optional
  content = [content, childcontent]
  childcontent = xsd_15_attributeGroup_Token_style_attrib_3_optional
  content = [content, childcontent]
  childcontent = xsd_15_attributeGroup_Token_style_attrib_4_optional
  content = [content, childcontent]
  content
end
# <attribute name="mathvariant"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional = begin
  choose(Bool) ? xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant : Any[]
end
# <attribute name="mathvariant"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant = begin
  content = xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType
  @assert typeof(content)<:String
  ("mathvariant", content)
end
# <simpleType/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_2_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_3_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_4_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_5_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_6_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_7_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_8_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_9_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_10_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_11_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_12_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_13_enumeration
end
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice = begin
  xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_14_enumeration
end
# <enumeration value="normal"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "normal"
end
# <enumeration value="bold"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "bold"
end
# <enumeration value="italic"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_3_enumeration = begin
  "italic"
end
# <enumeration value="bold-italic"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_4_enumeration = begin
  "bold-italic"
end
# <enumeration value="double-struck"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_5_enumeration = begin
  "double-struck"
end
# <enumeration value="bold-fraktur"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_6_enumeration = begin
  "bold-fraktur"
end
# <enumeration value="script"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_7_enumeration = begin
  "script"
end
# <enumeration value="bold-script"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_8_enumeration = begin
  "bold-script"
end
# <enumeration value="fraktur"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_9_enumeration = begin
  "fraktur"
end
# <enumeration value="sans-serif"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_10_enumeration = begin
  "sans-serif"
end
# <enumeration value="bold-sans-serif"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_11_enumeration = begin
  "bold-sans-serif"
end
# <enumeration value="sans-serif-italic"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_12_enumeration = begin
  "sans-serif-italic"
end
# <enumeration value="sans-serif-bold-italic"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_13_enumeration = begin
  "sans-serif-bold-italic"
end
# <enumeration value="monospace"/>
xsd_15_attributeGroup_Token_style_attrib_1_optional_1_attribute_mathvariant_1_simpleType_1_restriction_1_choice_14_enumeration = begin
  "monospace"
end
# <attribute name="mathsize"/>
xsd_15_attributeGroup_Token_style_attrib_2_optional = begin
  choose(Bool) ? xsd_15_attributeGroup_Token_style_attrib_2_optional_1_attribute_mathsize : Any[]
end
# <attribute name="mathsize"/>
xsd_15_attributeGroup_Token_style_attrib_2_optional_1_attribute_mathsize = begin
  content = xsd_15_attributeGroup_Token_style_attrib_2_optional_1_attribute_mathsize_1_simpleType
  @assert typeof(content)<:String
  ("mathsize", content)
end
# <simpleType/>
xsd_15_attributeGroup_Token_style_attrib_2_optional_1_attribute_mathsize_1_simpleType = begin
  xsd_15_attributeGroup_Token_style_attrib_2_optional_1_attribute_mathsize_1_simpleType_1_union
end
# <union memberTypes="simple-size length-with-unit"/>
xsd_15_attributeGroup_Token_style_attrib_2_optional_1_attribute_mathsize_1_simpleType_1_union = begin
  xsd_8_simpleType_simple_size
end
# <union memberTypes="simple-size length-with-unit"/>
xsd_15_attributeGroup_Token_style_attrib_2_optional_1_attribute_mathsize_1_simpleType_1_union = begin
  xsd_11_simpleType_length_with_unit
end
# <attribute name="mathcolor" type="domain-knowledge-color"/>
xsd_15_attributeGroup_Token_style_attrib_3_optional = begin
  choose(Bool) ? xsd_15_attributeGroup_Token_style_attrib_3_optional_1_attribute_mathcolor : Any[]
end
# <attribute name="mathcolor" type="domain-knowledge-color"/>
xsd_15_attributeGroup_Token_style_attrib_3_optional_1_attribute_mathcolor = begin
  content = xsd_16_simpleType_domain_knowledge_color
  @assert typeof(content)<:String
  ("mathcolor", content)
end
# <attribute name="mathbackground" type="domain-knowledge-color"/>
xsd_15_attributeGroup_Token_style_attrib_4_optional = begin
  choose(Bool) ? xsd_15_attributeGroup_Token_style_attrib_4_optional_1_attribute_mathbackground : Any[]
end
# <attribute name="mathbackground" type="domain-knowledge-color"/>
xsd_15_attributeGroup_Token_style_attrib_4_optional_1_attribute_mathbackground = begin
  content = xsd_16_simpleType_domain_knowledge_color
  @assert typeof(content)<:String
  ("mathbackground", content)
end
# <simpleType name="domain-knowledge-color"/>
xsd_16_simpleType_domain_knowledge_color = begin
  xsd_16_simpleType_domain_knowledge_color_1_union
end
# <union memberTypes="RGB-color domain-knowledge-named-colors"/>
xsd_16_simpleType_domain_knowledge_color_1_union = begin
  xsd_14_simpleType_RGB_color
end
# <union memberTypes="RGB-color domain-knowledge-named-colors"/>
xsd_16_simpleType_domain_knowledge_color_1_union = begin
  xsd_17_simpleType_domain_knowledge_named_colors
end
# <simpleType name="domain-knowledge-named-colors"/>
xsd_17_simpleType_domain_knowledge_named_colors = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction
end
# <restriction base="xs:string"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_1_enumeration
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_2_enumeration
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_3_enumeration
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_4_enumeration
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_5_enumeration
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_6_enumeration
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_7_enumeration
end
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice = begin
  xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_8_enumeration
end
# <enumeration value="red"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_1_enumeration = begin
  "red"
end
# <enumeration value="blue"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_2_enumeration = begin
  "blue"
end
# <enumeration value="black"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_3_enumeration = begin
  "black"
end
# <enumeration value="white"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_4_enumeration = begin
  "white"
end
# <enumeration value="green"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_5_enumeration = begin
  "green"
end
# <enumeration value="magenta"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_6_enumeration = begin
  "magenta"
end
# <enumeration value="yellow"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_7_enumeration = begin
  "yellow"
end
# <enumeration value="cyan"/>
xsd_17_simpleType_domain_knowledge_named_colors_1_restriction_1_choice_8_enumeration = begin
  "cyan"
end
# <attributeGroup name="Operator.attrib"/>
xsd_18_attributeGroup_Operator_attrib = begin
  content = (Any)[]
  childcontent = xsd_18_attributeGroup_Operator_attrib_1_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_2_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_3_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_4_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_5_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_6_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_7_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_8_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_9_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_10_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_11_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib_12_optional
  content = [content, childcontent]
  content
end
# <attribute name="form"/>
xsd_18_attributeGroup_Operator_attrib_1_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form : Any[]
end
# <attribute name="form"/>
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form = begin
  content = xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType
  @assert typeof(content)<:String
  ("form", content)
end
# <simpleType/>
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType = begin
  xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction = begin
  xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice
end
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice = begin
  xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice = begin
  xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice_2_enumeration
end
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice = begin
  xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice_3_enumeration
end
# <enumeration value="prefix"/>
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "prefix"
end
# <enumeration value="infix"/>
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "infix"
end
# <enumeration value="postfix"/>
xsd_18_attributeGroup_Operator_attrib_1_optional_1_attribute_form_1_simpleType_1_restriction_1_choice_3_enumeration = begin
  "postfix"
end
# <attribute name="lspace"/>
xsd_18_attributeGroup_Operator_attrib_2_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_2_optional_1_attribute_lspace : Any[]
end
# <attribute name="lspace"/>
xsd_18_attributeGroup_Operator_attrib_2_optional_1_attribute_lspace = begin
  content = xsd_18_attributeGroup_Operator_attrib_2_optional_1_attribute_lspace_1_simpleType
  @assert typeof(content)<:String
  ("lspace", content)
end
# <simpleType/>
xsd_18_attributeGroup_Operator_attrib_2_optional_1_attribute_lspace_1_simpleType = begin
  xsd_18_attributeGroup_Operator_attrib_2_optional_1_attribute_lspace_1_simpleType_1_union
end
# <union memberTypes="length-with-unit named-space"/>
xsd_18_attributeGroup_Operator_attrib_2_optional_1_attribute_lspace_1_simpleType_1_union = begin
  xsd_11_simpleType_length_with_unit
end
# <union memberTypes="length-with-unit named-space"/>
xsd_18_attributeGroup_Operator_attrib_2_optional_1_attribute_lspace_1_simpleType_1_union = begin
  xsd_9_simpleType_named_space
end
# <attribute name="rspace"/>
xsd_18_attributeGroup_Operator_attrib_3_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_3_optional_1_attribute_rspace : Any[]
end
# <attribute name="rspace"/>
xsd_18_attributeGroup_Operator_attrib_3_optional_1_attribute_rspace = begin
  content = xsd_18_attributeGroup_Operator_attrib_3_optional_1_attribute_rspace_1_simpleType
  @assert typeof(content)<:String
  ("rspace", content)
end
# <simpleType/>
xsd_18_attributeGroup_Operator_attrib_3_optional_1_attribute_rspace_1_simpleType = begin
  xsd_18_attributeGroup_Operator_attrib_3_optional_1_attribute_rspace_1_simpleType_1_union
end
# <union memberTypes="length-with-unit named-space"/>
xsd_18_attributeGroup_Operator_attrib_3_optional_1_attribute_rspace_1_simpleType_1_union = begin
  xsd_11_simpleType_length_with_unit
end
# <union memberTypes="length-with-unit named-space"/>
xsd_18_attributeGroup_Operator_attrib_3_optional_1_attribute_rspace_1_simpleType_1_union = begin
  xsd_9_simpleType_named_space
end
# <attribute name="fence" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_4_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_4_optional_1_attribute_fence : Any[]
end
# <attribute name="fence" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_4_optional_1_attribute_fence = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("fence", content)
end
# <attribute name="separator" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_5_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_5_optional_1_attribute_separator : Any[]
end
# <attribute name="separator" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_5_optional_1_attribute_separator = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("separator", content)
end
# <attribute name="stretchy" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_6_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_6_optional_1_attribute_stretchy : Any[]
end
# <attribute name="stretchy" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_6_optional_1_attribute_stretchy = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("stretchy", content)
end
# <attribute name="symmetric" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_7_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_7_optional_1_attribute_symmetric : Any[]
end
# <attribute name="symmetric" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_7_optional_1_attribute_symmetric = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("symmetric", content)
end
# <attribute name="movablelimits" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_8_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_8_optional_1_attribute_movablelimits : Any[]
end
# <attribute name="movablelimits" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_8_optional_1_attribute_movablelimits = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("movablelimits", content)
end
# <attribute name="accent" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_9_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_9_optional_1_attribute_accent : Any[]
end
# <attribute name="accent" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_9_optional_1_attribute_accent = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("accent", content)
end
# <attribute name="largeop" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_10_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_10_optional_1_attribute_largeop : Any[]
end
# <attribute name="largeop" type="xs:boolean"/>
xsd_18_attributeGroup_Operator_attrib_10_optional_1_attribute_largeop = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("largeop", content)
end
# <attribute name="minsize"/>
xsd_18_attributeGroup_Operator_attrib_11_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_11_optional_1_attribute_minsize : Any[]
end
# <attribute name="minsize"/>
xsd_18_attributeGroup_Operator_attrib_11_optional_1_attribute_minsize = begin
  content = xsd_18_attributeGroup_Operator_attrib_11_optional_1_attribute_minsize_1_simpleType
  @assert typeof(content)<:String
  ("minsize", content)
end
# <simpleType/>
xsd_18_attributeGroup_Operator_attrib_11_optional_1_attribute_minsize_1_simpleType = begin
  xsd_18_attributeGroup_Operator_attrib_11_optional_1_attribute_minsize_1_simpleType_1_union
end
# <union memberTypes="length-with-unit named-space"/>
xsd_18_attributeGroup_Operator_attrib_11_optional_1_attribute_minsize_1_simpleType_1_union = begin
  xsd_11_simpleType_length_with_unit
end
# <union memberTypes="length-with-unit named-space"/>
xsd_18_attributeGroup_Operator_attrib_11_optional_1_attribute_minsize_1_simpleType_1_union = begin
  xsd_9_simpleType_named_space
end
# <attribute name="maxsize"/>
xsd_18_attributeGroup_Operator_attrib_12_optional = begin
  choose(Bool) ? xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize : Any[]
end
# <attribute name="maxsize"/>
xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize = begin
  content = xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize_1_simpleType
  @assert typeof(content)<:String
  ("maxsize", content)
end
# <simpleType/>
xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize_1_simpleType = begin
  xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize_1_simpleType_1_union
end
# <union memberTypes="length-with-unit named-space infinity xs:float"/>
xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize_1_simpleType_1_union = begin
  xsd_11_simpleType_length_with_unit
end
# <union memberTypes="length-with-unit named-space infinity xs:float"/>
xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize_1_simpleType_1_union = begin
  xsd_9_simpleType_named_space
end
# <union memberTypes="length-with-unit named-space infinity xs:float"/>
xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize_1_simpleType_1_union = begin
  xsd_13_simpleType_infinity
end
# <union memberTypes="length-with-unit named-space infinity xs:float"/>
xsd_18_attributeGroup_Operator_attrib_12_optional_1_attribute_maxsize_1_simpleType_1_union = begin
  xsd_135_simpleType_xs_float
end
# <attributeGroup name="mglyph.attlist"/>
xsd_19_attributeGroup_mglyph_attlist = begin
  content = (Any)[]
  childcontent = xsd_19_attributeGroup_mglyph_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_19_attributeGroup_mglyph_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_19_attributeGroup_mglyph_attlist_3_optional
  content = [content, childcontent]
  content
end
# <attribute name="alt" type="xs:string"/>
xsd_19_attributeGroup_mglyph_attlist_1_optional = begin
  choose(Bool) ? xsd_19_attributeGroup_mglyph_attlist_1_optional_1_attribute_alt : Any[]
end
# <attribute name="alt" type="xs:string"/>
xsd_19_attributeGroup_mglyph_attlist_1_optional_1_attribute_alt = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("alt", content)
end
# <attribute name="fontfamily" type="domain-knowledge-font-family"/>
xsd_19_attributeGroup_mglyph_attlist_2_optional = begin
  choose(Bool) ? xsd_19_attributeGroup_mglyph_attlist_2_optional_1_attribute_fontfamily : Any[]
end
# <attribute name="fontfamily" type="domain-knowledge-font-family"/>
xsd_19_attributeGroup_mglyph_attlist_2_optional_1_attribute_fontfamily = begin
  content = xsd_20_simpleType_domain_knowledge_font_family
  @assert typeof(content)<:String
  ("fontfamily", content)
end
# <attribute name="index" type="xs:positiveInteger"/>
xsd_19_attributeGroup_mglyph_attlist_3_optional = begin
  choose(Bool) ? xsd_19_attributeGroup_mglyph_attlist_3_optional_1_attribute_index : Any[]
end
# <attribute name="index" type="xs:positiveInteger"/>
xsd_19_attributeGroup_mglyph_attlist_3_optional_1_attribute_index = begin
  content = xsd_136_simpleType_xs_positiveInteger
  @assert typeof(content)<:String
  ("index", content)
end
# <simpleType name="domain-knowledge-font-family"/>
xsd_20_simpleType_domain_knowledge_font_family = begin
  xsd_20_simpleType_domain_knowledge_font_family_1_restriction
end
# <restriction base="xs:string"/>
xsd_20_simpleType_domain_knowledge_font_family_1_restriction = begin
  xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice
end
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice = begin
  xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_1_enumeration
end
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice = begin
  xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_2_enumeration
end
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice = begin
  xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_3_enumeration
end
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice = begin
  xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_4_enumeration
end
# <enumeration value="Arial"/>
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_1_enumeration = begin
  "Arial"
end
# <enumeration value="Helvetica"/>
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_2_enumeration = begin
  "Helvetica"
end
# <enumeration value="Courier"/>
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_3_enumeration = begin
  "Courier"
end
# <enumeration value="Times"/>
xsd_20_simpleType_domain_knowledge_font_family_1_restriction_1_choice_4_enumeration = begin
  "Times"
end
# <complexType name="mglyph.type"/>
xsd_21_complexType_mglyph_type = begin
  content = (Any)[]
  childcontent = xsd_19_attributeGroup_mglyph_attlist
  content = [content, childcontent]
  content
end
# <element name="mglyph" type="mglyph.type"/>
xsd_22_element_mglyph = begin
  content = (Any)[]
  childcontent = xsd_21_complexType_mglyph_type
  content = [content, childcontent]
  construct_element("mglyph", content)
end
# <group name="Glyph-alignmark.class"/>
xsd_23_group_Glyph_alignmark_class = begin
  content = (Any)[]
  childcontent = xsd_23_group_Glyph_alignmark_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_23_group_Glyph_alignmark_class_1_choice = begin
  xsd_121_element_malignmark
end
# <choice/>
xsd_23_group_Glyph_alignmark_class_1_choice = begin
  xsd_22_element_mglyph
end
# <attributeGroup name="mi.attlist"/>
xsd_24_attributeGroup_mi_attlist = begin
  content = (Any)[]
  childcontent = xsd_15_attributeGroup_Token_style_attrib
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="mi.type" mixed="true"/>
xsd_25_complexType_mi_type = begin
  content = (Any)[]
  childcontent = xsd_25_complexType_mi_type_1_optional
  content = [content, childcontent]
  childcontent = xsd_23_group_Glyph_alignmark_class
  content = [content, childcontent]
  childcontent = xsd_25_complexType_mi_type_3_optional
  content = [content, childcontent]
  childcontent = xsd_24_attributeGroup_mi_attlist
  content = [content, childcontent]
  content
end
xsd_25_complexType_mi_type_1_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
xsd_25_complexType_mi_type_3_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
# <element name="mi" type="mi.type"/>
xsd_26_element_mi = begin
  content = (Any)[]
  childcontent = xsd_25_complexType_mi_type
  content = [content, childcontent]
  construct_element("mi", content)
end
# <attributeGroup name="mo.attlist"/>
xsd_27_attributeGroup_mo_attlist = begin
  content = (Any)[]
  childcontent = xsd_18_attributeGroup_Operator_attrib
  content = [content, childcontent]
  childcontent = xsd_15_attributeGroup_Token_style_attrib
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="mo.type" mixed="true"/>
xsd_28_complexType_mo_type = begin
  content = (Any)[]
  childcontent = xsd_28_complexType_mo_type_1_optional
  content = [content, childcontent]
  childcontent = xsd_23_group_Glyph_alignmark_class
  content = [content, childcontent]
  childcontent = xsd_28_complexType_mo_type_3_optional
  content = [content, childcontent]
  childcontent = xsd_27_attributeGroup_mo_attlist
  content = [content, childcontent]
  content
end
xsd_28_complexType_mo_type_1_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
xsd_28_complexType_mo_type_3_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
# <element name="mo" type="mo.type"/>
xsd_29_element_mo = begin
  content = (Any)[]
  childcontent = xsd_28_complexType_mo_type
  content = [content, childcontent]
  construct_element("mo", content)
end
# <complexType name="mn.type" mixed="true"/>
xsd_30_complexType_mn_type = begin
  content = (Any)[]
  childcontent = xsd_30_complexType_mn_type_1_optional
  content = [content, childcontent]
  childcontent = xsd_23_group_Glyph_alignmark_class
  content = [content, childcontent]
  childcontent = xsd_30_complexType_mn_type_3_optional
  content = [content, childcontent]
  childcontent = xsd_24_attributeGroup_mi_attlist
  content = [content, childcontent]
  content
end
xsd_30_complexType_mn_type_1_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
xsd_30_complexType_mn_type_3_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
# <element name="mn" type="mn.type"/>
xsd_31_element_mn = begin
  content = (Any)[]
  childcontent = xsd_30_complexType_mn_type
  content = [content, childcontent]
  construct_element("mn", content)
end
# <attributeGroup name="mtext.attlist"/>
xsd_32_attributeGroup_mtext_attlist = begin
  content = (Any)[]
  childcontent = xsd_15_attributeGroup_Token_style_attrib
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="mtext.type" mixed="true"/>
xsd_33_complexType_mtext_type = begin
  content = (Any)[]
  childcontent = xsd_33_complexType_mtext_type_1_optional
  content = [content, childcontent]
  childcontent = xsd_23_group_Glyph_alignmark_class
  content = [content, childcontent]
  childcontent = xsd_33_complexType_mtext_type_3_optional
  content = [content, childcontent]
  childcontent = xsd_32_attributeGroup_mtext_attlist
  content = [content, childcontent]
  content
end
xsd_33_complexType_mtext_type_1_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
xsd_33_complexType_mtext_type_3_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
# <element name="mtext" type="mtext.type"/>
xsd_34_element_mtext = begin
  content = (Any)[]
  childcontent = xsd_33_complexType_mtext_type
  content = [content, childcontent]
  construct_element("mtext", content)
end
# <attributeGroup name="ms.attlist"/>
xsd_35_attributeGroup_ms_attlist = begin
  content = (Any)[]
  childcontent = xsd_35_attributeGroup_ms_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_35_attributeGroup_ms_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_15_attributeGroup_Token_style_attrib
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="lquote" default="&quot;" type="xs:string"/>
xsd_35_attributeGroup_ms_attlist_1_optional = begin
  choose(Bool) ? xsd_35_attributeGroup_ms_attlist_1_optional_1_attribute_lquote : Any[]
end
# <attribute name="lquote" default="&quot;" type="xs:string"/>
xsd_35_attributeGroup_ms_attlist_1_optional_1_attribute_lquote = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("lquote", content)
end
# <attribute name="rquote" default="&quot;" type="xs:string"/>
xsd_35_attributeGroup_ms_attlist_2_optional = begin
  choose(Bool) ? xsd_35_attributeGroup_ms_attlist_2_optional_1_attribute_rquote : Any[]
end
# <attribute name="rquote" default="&quot;" type="xs:string"/>
xsd_35_attributeGroup_ms_attlist_2_optional_1_attribute_rquote = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("rquote", content)
end
# <complexType name="ms.type" mixed="true"/>
xsd_36_complexType_ms_type = begin
  content = (Any)[]
  childcontent = xsd_36_complexType_ms_type_1_optional
  content = [content, childcontent]
  childcontent = xsd_23_group_Glyph_alignmark_class
  content = [content, childcontent]
  childcontent = xsd_36_complexType_ms_type_3_optional
  content = [content, childcontent]
  childcontent = xsd_35_attributeGroup_ms_attlist
  content = [content, childcontent]
  content
end
xsd_36_complexType_ms_type_1_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
xsd_36_complexType_ms_type_3_optional = begin
  choose(Bool) ? xsd_131_simpleType_xs_string : Any[]
end
# <element name="ms" type="ms.type"/>
xsd_37_element_ms = begin
  content = (Any)[]
  childcontent = xsd_36_complexType_ms_type
  content = [content, childcontent]
  construct_element("ms", content)
end
# <group name="Presentation-token.class"/>
xsd_38_group_Presentation_token_class = begin
  content = (Any)[]
  childcontent = xsd_38_group_Presentation_token_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_38_group_Presentation_token_class_1_choice = begin
  xsd_26_element_mi
end
# <choice/>
xsd_38_group_Presentation_token_class_1_choice = begin
  xsd_29_element_mo
end
# <choice/>
xsd_38_group_Presentation_token_class_1_choice = begin
  xsd_31_element_mn
end
# <choice/>
xsd_38_group_Presentation_token_class_1_choice = begin
  xsd_34_element_mtext
end
# <choice/>
xsd_38_group_Presentation_token_class_1_choice = begin
  xsd_37_element_ms
end
# <attributeGroup name="msub.attlist"/>
xsd_39_attributeGroup_msub_attlist = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="msub.type"/>
xsd_40_complexType_msub_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_39_attributeGroup_msub_attlist
  content = [content, childcontent]
  content
end
# <element name="msub" type="msub.type"/>
xsd_41_element_msub = begin
  content = (Any)[]
  childcontent = xsd_40_complexType_msub_type
  content = [content, childcontent]
  construct_element("msub", content)
end
# <attributeGroup name="msup.attlist"/>
xsd_42_attributeGroup_msup_attlist = begin
  content = (Any)[]
  childcontent = xsd_42_attributeGroup_msup_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="superscriptshift" type="length-with-unit"/>
xsd_42_attributeGroup_msup_attlist_1_optional = begin
  choose(Bool) ? xsd_42_attributeGroup_msup_attlist_1_optional_1_attribute_superscriptshift : Any[]
end
# <attribute name="superscriptshift" type="length-with-unit"/>
xsd_42_attributeGroup_msup_attlist_1_optional_1_attribute_superscriptshift = begin
  content = xsd_11_simpleType_length_with_unit
  @assert typeof(content)<:String
  ("superscriptshift", content)
end
# <complexType name="msup.type"/>
xsd_43_complexType_msup_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_42_attributeGroup_msup_attlist
  content = [content, childcontent]
  content
end
# <element name="msup" type="msup.type"/>
xsd_44_element_msup = begin
  content = (Any)[]
  childcontent = xsd_43_complexType_msup_type
  content = [content, childcontent]
  construct_element("msup", content)
end
# <attributeGroup name="msubsup.attlist"/>
xsd_45_attributeGroup_msubsup_attlist = begin
  content = (Any)[]
  childcontent = xsd_45_attributeGroup_msubsup_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="superscriptshift" type="length-with-unit"/>
xsd_45_attributeGroup_msubsup_attlist_1_optional = begin
  choose(Bool) ? xsd_45_attributeGroup_msubsup_attlist_1_optional_1_attribute_superscriptshift : Any[]
end
# <attribute name="superscriptshift" type="length-with-unit"/>
xsd_45_attributeGroup_msubsup_attlist_1_optional_1_attribute_superscriptshift = begin
  content = xsd_11_simpleType_length_with_unit
  @assert typeof(content)<:String
  ("superscriptshift", content)
end
# <complexType name="msubsup.type"/>
xsd_46_complexType_msubsup_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_45_attributeGroup_msubsup_attlist
  content = [content, childcontent]
  content
end
# <element name="msubsup" type="msubsup.type"/>
xsd_47_element_msubsup = begin
  content = (Any)[]
  childcontent = xsd_46_complexType_msubsup_type
  content = [content, childcontent]
  construct_element("msubsup", content)
end
# <attributeGroup name="munder.attlist"/>
xsd_48_attributeGroup_munder_attlist = begin
  content = (Any)[]
  childcontent = xsd_48_attributeGroup_munder_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="accentunder" type="xs:boolean"/>
xsd_48_attributeGroup_munder_attlist_1_optional = begin
  choose(Bool) ? xsd_48_attributeGroup_munder_attlist_1_optional_1_attribute_accentunder : Any[]
end
# <attribute name="accentunder" type="xs:boolean"/>
xsd_48_attributeGroup_munder_attlist_1_optional_1_attribute_accentunder = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("accentunder", content)
end
# <complexType name="munder.type"/>
xsd_49_complexType_munder_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_48_attributeGroup_munder_attlist
  content = [content, childcontent]
  content
end
# <element name="munder" type="munder.type"/>
xsd_50_element_munder = begin
  content = (Any)[]
  childcontent = xsd_49_complexType_munder_type
  content = [content, childcontent]
  construct_element("munder", content)
end
# <attributeGroup name="mover.attlist"/>
xsd_51_attributeGroup_mover_attlist = begin
  content = (Any)[]
  childcontent = xsd_51_attributeGroup_mover_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="accent" type="xs:boolean"/>
xsd_51_attributeGroup_mover_attlist_1_optional = begin
  choose(Bool) ? xsd_51_attributeGroup_mover_attlist_1_optional_1_attribute_accent : Any[]
end
# <attribute name="accent" type="xs:boolean"/>
xsd_51_attributeGroup_mover_attlist_1_optional_1_attribute_accent = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("accent", content)
end
# <complexType name="mover.type"/>
xsd_52_complexType_mover_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_51_attributeGroup_mover_attlist
  content = [content, childcontent]
  content
end
# <element name="mover" type="mover.type"/>
xsd_53_element_mover = begin
  content = (Any)[]
  childcontent = xsd_52_complexType_mover_type
  content = [content, childcontent]
  construct_element("mover", content)
end
# <attributeGroup name="munderover.attlist"/>
xsd_54_attributeGroup_munderover_attlist = begin
  content = (Any)[]
  childcontent = xsd_54_attributeGroup_munderover_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="accent" type="xs:boolean"/>
xsd_54_attributeGroup_munderover_attlist_1_optional = begin
  choose(Bool) ? xsd_54_attributeGroup_munderover_attlist_1_optional_1_attribute_accent : Any[]
end
# <attribute name="accent" type="xs:boolean"/>
xsd_54_attributeGroup_munderover_attlist_1_optional_1_attribute_accent = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("accent", content)
end
# <complexType name="munderover.type"/>
xsd_55_complexType_munderover_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_54_attributeGroup_munderover_attlist
  content = [content, childcontent]
  content
end
# <element name="munderover" type="munderover.type"/>
xsd_56_element_munderover = begin
  content = (Any)[]
  childcontent = xsd_55_complexType_munderover_type
  content = [content, childcontent]
  construct_element("munderover", content)
end
# <attributeGroup name="mmultiscripts.attlist"/>
xsd_57_attributeGroup_mmultiscripts_attlist = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <group name="Presentation-expr-or-none.class"/>
xsd_58_group_Presentation_expr_or_none_class = begin
  content = (Any)[]
  childcontent = xsd_58_group_Presentation_expr_or_none_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_58_group_Presentation_expr_or_none_class_1_choice = begin
  xsd_1_group_Presentation_expr_class
end
# <choice/>
xsd_58_group_Presentation_expr_or_none_class_1_choice = begin
  xsd_63_element_none
end
# <group name="mmultiscripts.content"/>
xsd_59_group_mmultiscripts_content = begin
  content = (Any)[]
  childcontent = xsd_59_group_mmultiscripts_content_1_sequence
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_59_group_mmultiscripts_content_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_59_group_mmultiscripts_content_1_sequence_2_quantifier
  content = [content, childcontent]
  childcontent = xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier
  content = [content, childcontent]
  content
end
# <sequence minOccurs="0" maxOccurs="unbounded"/>
xsd_59_group_mmultiscripts_content_1_sequence_2_quantifier = begin
  r = reps(xsd_59_group_mmultiscripts_content_1_sequence_2_quantifier_1_sequence, 0)
  reduce((v,e)->[v,e], Any[], r)
end
# <sequence minOccurs="0" maxOccurs="unbounded"/>
xsd_59_group_mmultiscripts_content_1_sequence_2_quantifier_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_58_group_Presentation_expr_or_none_class
  content = [content, childcontent]
  childcontent = xsd_58_group_Presentation_expr_or_none_class
  content = [content, childcontent]
  content
end
# <sequence minOccurs="0"/>
xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier = begin
  r = reps(xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier_1_sequence, 0, 1)
  reduce((v,e)->[v,e], Any[], r)
end
# <sequence minOccurs="0"/>
xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_65_element_mprescripts
  content = [content, childcontent]
  childcontent = xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier_1_sequence_2_quantifier
  content = [content, childcontent]
  content
end
# <sequence maxOccurs="unbounded"/>
xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier_1_sequence_2_quantifier = begin
  r = reps(xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier_1_sequence_2_quantifier_1_sequence, 1)
  reduce((v,e)->[v,e], Any[], r)
end
# <sequence maxOccurs="unbounded"/>
xsd_59_group_mmultiscripts_content_1_sequence_3_quantifier_1_sequence_2_quantifier_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_58_group_Presentation_expr_or_none_class
  content = [content, childcontent]
  childcontent = xsd_58_group_Presentation_expr_or_none_class
  content = [content, childcontent]
  content
end
# <complexType name="mmultiscripts.type"/>
xsd_60_complexType_mmultiscripts_type = begin
  content = (Any)[]
  childcontent = xsd_59_group_mmultiscripts_content
  content = [content, childcontent]
  childcontent = xsd_57_attributeGroup_mmultiscripts_attlist
  content = [content, childcontent]
  content
end
# <element name="mmultiscripts" type="mmultiscripts.type"/>
xsd_61_element_mmultiscripts = begin
  content = (Any)[]
  childcontent = xsd_60_complexType_mmultiscripts_type
  content = [content, childcontent]
  construct_element("mmultiscripts", content)
end
# <complexType name="none.type"/>
xsd_62_complexType_none_type = begin
  content = (Any)[]
  content
end
# <element name="none" type="none.type"/>
xsd_63_element_none = begin
  content = (Any)[]
  childcontent = xsd_62_complexType_none_type
  content = [content, childcontent]
  construct_element("none", content)
end
# <complexType name="mprescripts.type"/>
xsd_64_complexType_mprescripts_type = begin
  content = (Any)[]
  content
end
# <element name="mprescripts" type="mprescripts.type"/>
xsd_65_element_mprescripts = begin
  content = (Any)[]
  childcontent = xsd_64_complexType_mprescripts_type
  content = [content, childcontent]
  construct_element("mprescripts", content)
end
# <group name="Presentation-script.class"/>
xsd_66_group_Presentation_script_class = begin
  content = (Any)[]
  childcontent = xsd_66_group_Presentation_script_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_66_group_Presentation_script_class_1_choice = begin
  xsd_41_element_msub
end
# <choice/>
xsd_66_group_Presentation_script_class_1_choice = begin
  xsd_44_element_msup
end
# <choice/>
xsd_66_group_Presentation_script_class_1_choice = begin
  xsd_47_element_msubsup
end
# <choice/>
xsd_66_group_Presentation_script_class_1_choice = begin
  xsd_50_element_munder
end
# <choice/>
xsd_66_group_Presentation_script_class_1_choice = begin
  xsd_53_element_mover
end
# <choice/>
xsd_66_group_Presentation_script_class_1_choice = begin
  xsd_56_element_munderover
end
# <choice/>
xsd_66_group_Presentation_script_class_1_choice = begin
  xsd_61_element_mmultiscripts
end
# <attributeGroup name="mspace.attlist"/>
xsd_67_attributeGroup_mspace_attlist = begin
  content = (Any)[]
  childcontent = xsd_67_attributeGroup_mspace_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_67_attributeGroup_mspace_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_67_attributeGroup_mspace_attlist_3_optional
  content = [content, childcontent]
  childcontent = xsd_67_attributeGroup_mspace_attlist_4_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="width" default="0em"/>
xsd_67_attributeGroup_mspace_attlist_1_optional = begin
  choose(Bool) ? xsd_67_attributeGroup_mspace_attlist_1_optional_1_attribute_width : Any[]
end
# <attribute name="width" default="0em"/>
xsd_67_attributeGroup_mspace_attlist_1_optional_1_attribute_width = begin
  content = xsd_67_attributeGroup_mspace_attlist_1_optional_1_attribute_width_1_simpleType
  @assert typeof(content)<:String
  ("width", content)
end
# <simpleType/>
xsd_67_attributeGroup_mspace_attlist_1_optional_1_attribute_width_1_simpleType = begin
  xsd_67_attributeGroup_mspace_attlist_1_optional_1_attribute_width_1_simpleType_1_union
end
# <union memberTypes="length-with-unit named-space"/>
xsd_67_attributeGroup_mspace_attlist_1_optional_1_attribute_width_1_simpleType_1_union = begin
  xsd_11_simpleType_length_with_unit
end
# <union memberTypes="length-with-unit named-space"/>
xsd_67_attributeGroup_mspace_attlist_1_optional_1_attribute_width_1_simpleType_1_union = begin
  xsd_9_simpleType_named_space
end
# <attribute name="height" default="0ex" type="length-with-unit"/>
xsd_67_attributeGroup_mspace_attlist_2_optional = begin
  choose(Bool) ? xsd_67_attributeGroup_mspace_attlist_2_optional_1_attribute_height : Any[]
end
# <attribute name="height" default="0ex" type="length-with-unit"/>
xsd_67_attributeGroup_mspace_attlist_2_optional_1_attribute_height = begin
  content = xsd_11_simpleType_length_with_unit
  @assert typeof(content)<:String
  ("height", content)
end
# <attribute name="depth" default="0ex" type="length-with-unit"/>
xsd_67_attributeGroup_mspace_attlist_3_optional = begin
  choose(Bool) ? xsd_67_attributeGroup_mspace_attlist_3_optional_1_attribute_depth : Any[]
end
# <attribute name="depth" default="0ex" type="length-with-unit"/>
xsd_67_attributeGroup_mspace_attlist_3_optional_1_attribute_depth = begin
  content = xsd_11_simpleType_length_with_unit
  @assert typeof(content)<:String
  ("depth", content)
end
# <attribute name="linebreak" default="auto"/>
xsd_67_attributeGroup_mspace_attlist_4_optional = begin
  choose(Bool) ? xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak : Any[]
end
# <attribute name="linebreak" default="auto"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak = begin
  content = xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType
  @assert typeof(content)<:String
  ("linebreak", content)
end
# <simpleType/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice
end
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_2_enumeration
end
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_3_enumeration
end
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_4_enumeration
end
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_5_enumeration
end
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice = begin
  xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_6_enumeration
end
# <enumeration value="auto"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "auto"
end
# <enumeration value="newline"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "newline"
end
# <enumeration value="indentingnewline"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_3_enumeration = begin
  "indentingnewline"
end
# <enumeration value="nobreak"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_4_enumeration = begin
  "nobreak"
end
# <enumeration value="goodbreak"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_5_enumeration = begin
  "goodbreak"
end
# <enumeration value="badbreak"/>
xsd_67_attributeGroup_mspace_attlist_4_optional_1_attribute_linebreak_1_simpleType_1_restriction_1_choice_6_enumeration = begin
  "badbreak"
end
# <complexType name="mspace.type"/>
xsd_68_complexType_mspace_type = begin
  content = (Any)[]
  childcontent = xsd_67_attributeGroup_mspace_attlist
  content = [content, childcontent]
  content
end
# <element name="mspace" type="mspace.type"/>
xsd_69_element_mspace = begin
  content = (Any)[]
  childcontent = xsd_68_complexType_mspace_type
  content = [content, childcontent]
  construct_element("mspace", content)
end
# <attributeGroup name="mrow.attlist"/>
xsd_70_attributeGroup_mrow_attlist = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="mrow.type"/>
xsd_71_complexType_mrow_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_70_attributeGroup_mrow_attlist
  content = [content, childcontent]
  content
end
# <element name="mrow" type="mrow.type"/>
xsd_72_element_mrow = begin
  content = (Any)[]
  childcontent = xsd_71_complexType_mrow_type
  content = [content, childcontent]
  construct_element("mrow", content)
end
# <attributeGroup name="mfrac.attlist"/>
xsd_73_attributeGroup_mfrac_attlist = begin
  content = (Any)[]
  childcontent = xsd_73_attributeGroup_mfrac_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_73_attributeGroup_mfrac_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="bevelled" type="xs:boolean"/>
xsd_73_attributeGroup_mfrac_attlist_1_optional = begin
  choose(Bool) ? xsd_73_attributeGroup_mfrac_attlist_1_optional_1_attribute_bevelled : Any[]
end
# <attribute name="bevelled" type="xs:boolean"/>
xsd_73_attributeGroup_mfrac_attlist_1_optional_1_attribute_bevelled = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("bevelled", content)
end
# <attribute name="linethickness" default="1"/>
xsd_73_attributeGroup_mfrac_attlist_2_optional = begin
  choose(Bool) ? xsd_73_attributeGroup_mfrac_attlist_2_optional_1_attribute_linethickness : Any[]
end
# <attribute name="linethickness" default="1"/>
xsd_73_attributeGroup_mfrac_attlist_2_optional_1_attribute_linethickness = begin
  content = xsd_73_attributeGroup_mfrac_attlist_2_optional_1_attribute_linethickness_1_simpleType
  @assert typeof(content)<:String
  ("linethickness", content)
end
# <simpleType/>
xsd_73_attributeGroup_mfrac_attlist_2_optional_1_attribute_linethickness_1_simpleType = begin
  xsd_73_attributeGroup_mfrac_attlist_2_optional_1_attribute_linethickness_1_simpleType_1_union
end
# <union memberTypes="length-with-optional-unit thickness"/>
xsd_73_attributeGroup_mfrac_attlist_2_optional_1_attribute_linethickness_1_simpleType_1_union = begin
  xsd_12_simpleType_length_with_optional_unit
end
# <union memberTypes="length-with-optional-unit thickness"/>
xsd_73_attributeGroup_mfrac_attlist_2_optional_1_attribute_linethickness_1_simpleType_1_union = begin
  xsd_10_simpleType_thickness
end
# <complexType name="mfrac.type"/>
xsd_74_complexType_mfrac_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_73_attributeGroup_mfrac_attlist
  content = [content, childcontent]
  content
end
# <element name="mfrac" type="mfrac.type"/>
xsd_75_element_mfrac = begin
  content = (Any)[]
  childcontent = xsd_74_complexType_mfrac_type
  content = [content, childcontent]
  construct_element("mfrac", content)
end
# <attributeGroup name="msqrt.attlist"/>
xsd_76_attributeGroup_msqrt_attlist = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="msqrt.type"/>
xsd_77_complexType_msqrt_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_76_attributeGroup_msqrt_attlist
  content = [content, childcontent]
  content
end
# <element name="msqrt" type="msqrt.type"/>
xsd_78_element_msqrt = begin
  content = (Any)[]
  childcontent = xsd_77_complexType_msqrt_type
  content = [content, childcontent]
  construct_element("msqrt", content)
end
# <attributeGroup name="mroot.attlist"/>
xsd_79_attributeGroup_mroot_attlist = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="mroot.type"/>
xsd_80_complexType_mroot_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_79_attributeGroup_mroot_attlist
  content = [content, childcontent]
  content
end
# <element name="mroot" type="mroot.type"/>
xsd_81_element_mroot = begin
  content = (Any)[]
  childcontent = xsd_80_complexType_mroot_type
  content = [content, childcontent]
  construct_element("mroot", content)
end
# <simpleType name="mpadded-space"/>
xsd_82_simpleType_mpadded_space = begin
  xsd_82_simpleType_mpadded_space_1_restriction
end
# <restriction base="xs:string"/>
xsd_82_simpleType_mpadded_space_1_restriction = begin
  xsd_82_simpleType_mpadded_space_1_restriction_1_choice
end
xsd_82_simpleType_mpadded_space_1_restriction_1_choice = begin
  xsd_82_simpleType_mpadded_space_1_restriction_1_choice_1_pattern
end
# <pattern value="(\+|-)?([0-9]+|[0-9]*\.[0-9]+)(((%?) *(width|lspace|height|depth))|(em|ex|px|in|cm|mm|pt|pc))"/>
xsd_82_simpleType_mpadded_space_1_restriction_1_choice_1_pattern = begin
  choose(ASCIIString, "(\\+|-)?([0-9]+|[0-9]*\\.[0-9]+)(((%?) *(width|lspace|height|depth))|(em|ex|px|in|cm|mm|pt|pc))")
end
# <simpleType name="mpadded-width-space"/>
xsd_83_simpleType_mpadded_width_space = begin
  xsd_83_simpleType_mpadded_width_space_1_restriction
end
# <restriction base="xs:string"/>
xsd_83_simpleType_mpadded_width_space_1_restriction = begin
  xsd_83_simpleType_mpadded_width_space_1_restriction_1_choice
end
xsd_83_simpleType_mpadded_width_space_1_restriction_1_choice = begin
  xsd_83_simpleType_mpadded_width_space_1_restriction_1_choice_1_pattern
end
# <pattern value="((\+|-)?([0-9]+|[0-9]*\.[0-9]+)(((%?) *(width|lspace|height|depth)?)|(width|lspace|height|depth)|(em|ex|px|in|cm|mm|pt|pc)))|((veryverythin|verythin|thin|medium|thick|verythick|veryverythick)mathspace)|0"/>
xsd_83_simpleType_mpadded_width_space_1_restriction_1_choice_1_pattern = begin
  choose(ASCIIString, "((\\+|-)?([0-9]+|[0-9]*\\.[0-9]+)(((%?) *(width|lspace|height|depth)?)|(width|lspace|height|depth)|(em|ex|px|in|cm|mm|pt|pc)))|((veryverythin|verythin|thin|medium|thick|verythick|veryverythick)mathspace)|0")
end
# <attributeGroup name="mpadded.attlist"/>
xsd_84_attributeGroup_mpadded_attlist = begin
  content = (Any)[]
  childcontent = xsd_84_attributeGroup_mpadded_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_84_attributeGroup_mpadded_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_84_attributeGroup_mpadded_attlist_3_optional
  content = [content, childcontent]
  childcontent = xsd_84_attributeGroup_mpadded_attlist_4_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="width" type="mpadded-width-space"/>
xsd_84_attributeGroup_mpadded_attlist_1_optional = begin
  choose(Bool) ? xsd_84_attributeGroup_mpadded_attlist_1_optional_1_attribute_width : Any[]
end
# <attribute name="width" type="mpadded-width-space"/>
xsd_84_attributeGroup_mpadded_attlist_1_optional_1_attribute_width = begin
  content = xsd_83_simpleType_mpadded_width_space
  @assert typeof(content)<:String
  ("width", content)
end
# <attribute name="lspace" type="mpadded-space"/>
xsd_84_attributeGroup_mpadded_attlist_2_optional = begin
  choose(Bool) ? xsd_84_attributeGroup_mpadded_attlist_2_optional_1_attribute_lspace : Any[]
end
# <attribute name="lspace" type="mpadded-space"/>
xsd_84_attributeGroup_mpadded_attlist_2_optional_1_attribute_lspace = begin
  content = xsd_82_simpleType_mpadded_space
  @assert typeof(content)<:String
  ("lspace", content)
end
# <attribute name="height" type="mpadded-space"/>
xsd_84_attributeGroup_mpadded_attlist_3_optional = begin
  choose(Bool) ? xsd_84_attributeGroup_mpadded_attlist_3_optional_1_attribute_height : Any[]
end
# <attribute name="height" type="mpadded-space"/>
xsd_84_attributeGroup_mpadded_attlist_3_optional_1_attribute_height = begin
  content = xsd_82_simpleType_mpadded_space
  @assert typeof(content)<:String
  ("height", content)
end
# <attribute name="depth" type="mpadded-space"/>
xsd_84_attributeGroup_mpadded_attlist_4_optional = begin
  choose(Bool) ? xsd_84_attributeGroup_mpadded_attlist_4_optional_1_attribute_depth : Any[]
end
# <attribute name="depth" type="mpadded-space"/>
xsd_84_attributeGroup_mpadded_attlist_4_optional_1_attribute_depth = begin
  content = xsd_82_simpleType_mpadded_space
  @assert typeof(content)<:String
  ("depth", content)
end
# <complexType name="mpadded.type"/>
xsd_85_complexType_mpadded_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_84_attributeGroup_mpadded_attlist
  content = [content, childcontent]
  content
end
# <element name="mpadded" type="mpadded.type"/>
xsd_86_element_mpadded = begin
  content = (Any)[]
  childcontent = xsd_85_complexType_mpadded_type
  content = [content, childcontent]
  construct_element("mpadded", content)
end
# <attributeGroup name="mphantom.attlist"/>
xsd_87_attributeGroup_mphantom_attlist = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="mphantom.type"/>
xsd_88_complexType_mphantom_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_87_attributeGroup_mphantom_attlist
  content = [content, childcontent]
  content
end
# <element name="mphantom" type="mphantom.type"/>
xsd_89_element_mphantom = begin
  content = (Any)[]
  childcontent = xsd_88_complexType_mphantom_type
  content = [content, childcontent]
  construct_element("mphantom", content)
end
# <attributeGroup name="mfenced.attlist"/>
xsd_90_attributeGroup_mfenced_attlist = begin
  content = (Any)[]
  childcontent = xsd_90_attributeGroup_mfenced_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_90_attributeGroup_mfenced_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_90_attributeGroup_mfenced_attlist_3_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="open" default="(" type="xs:string"/>
xsd_90_attributeGroup_mfenced_attlist_1_optional = begin
  choose(Bool) ? xsd_90_attributeGroup_mfenced_attlist_1_optional_1_attribute_open : Any[]
end
# <attribute name="open" default="(" type="xs:string"/>
xsd_90_attributeGroup_mfenced_attlist_1_optional_1_attribute_open = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("open", content)
end
# <attribute name="close" default=")" type="xs:string"/>
xsd_90_attributeGroup_mfenced_attlist_2_optional = begin
  choose(Bool) ? xsd_90_attributeGroup_mfenced_attlist_2_optional_1_attribute_close : Any[]
end
# <attribute name="close" default=")" type="xs:string"/>
xsd_90_attributeGroup_mfenced_attlist_2_optional_1_attribute_close = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("close", content)
end
# <attribute name="separators" default="," type="xs:string"/>
xsd_90_attributeGroup_mfenced_attlist_3_optional = begin
  choose(Bool) ? xsd_90_attributeGroup_mfenced_attlist_3_optional_1_attribute_separators : Any[]
end
# <attribute name="separators" default="," type="xs:string"/>
xsd_90_attributeGroup_mfenced_attlist_3_optional_1_attribute_separators = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("separators", content)
end
# <complexType name="mfenced.type"/>
xsd_91_complexType_mfenced_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_90_attributeGroup_mfenced_attlist
  content = [content, childcontent]
  content
end
# <element name="mfenced" type="mfenced.type"/>
xsd_92_element_mfenced = begin
  content = (Any)[]
  childcontent = xsd_91_complexType_mfenced_type
  content = [content, childcontent]
  construct_element("mfenced", content)
end
# <attributeGroup name="menclose.attlist"/>
xsd_93_attributeGroup_menclose_attlist = begin
  content = (Any)[]
  childcontent = xsd_93_attributeGroup_menclose_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="notation" default="longdiv"/>
xsd_93_attributeGroup_menclose_attlist_1_optional = begin
  choose(Bool) ? xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation : Any[]
end
# <attribute name="notation" default="longdiv"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation = begin
  content = xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType
  @assert typeof(content)<:String
  ("notation", content)
end
# <simpleType/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_2_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_3_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_4_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_5_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_6_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_7_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_8_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_9_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_10_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_11_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_12_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_13_enumeration
end
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice = begin
  xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_14_enumeration
end
# <enumeration value="actuarial"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "actuarial"
end
# <enumeration value="longdiv"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "longdiv"
end
# <enumeration value="radical"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_3_enumeration = begin
  "radical"
end
# <enumeration value="box"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_4_enumeration = begin
  "box"
end
# <enumeration value="roundedbox"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_5_enumeration = begin
  "roundedbox"
end
# <enumeration value="circle"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_6_enumeration = begin
  "circle"
end
# <enumeration value="left"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_7_enumeration = begin
  "left"
end
# <enumeration value="right"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_8_enumeration = begin
  "right"
end
# <enumeration value="top"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_9_enumeration = begin
  "top"
end
# <enumeration value="bottom"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_10_enumeration = begin
  "bottom"
end
# <enumeration value="updiagonalstrike"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_11_enumeration = begin
  "updiagonalstrike"
end
# <enumeration value="downdiagonalstrike"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_12_enumeration = begin
  "downdiagonalstrike"
end
# <enumeration value="verticalstrike"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_13_enumeration = begin
  "verticalstrike"
end
# <enumeration value="horizontalstrike"/>
xsd_93_attributeGroup_menclose_attlist_1_optional_1_attribute_notation_1_simpleType_1_restriction_1_choice_14_enumeration = begin
  "horizontalstrike"
end
# <complexType name="menclose.type"/>
xsd_94_complexType_menclose_type = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  childcontent = xsd_93_attributeGroup_menclose_attlist
  content = [content, childcontent]
  content
end
# <element name="menclose" type="menclose.type"/>
xsd_95_element_menclose = begin
  content = (Any)[]
  childcontent = xsd_94_complexType_menclose_type
  content = [content, childcontent]
  construct_element("menclose", content)
end
# <group name="Presentation-layout.class"/>
xsd_96_group_Presentation_layout_class = begin
  content = (Any)[]
  childcontent = xsd_96_group_Presentation_layout_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_72_element_mrow
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_75_element_mfrac
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_78_element_msqrt
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_81_element_mroot
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_86_element_mpadded
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_89_element_mphantom
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_92_element_mfenced
end
# <choice/>
xsd_96_group_Presentation_layout_class_1_choice = begin
  xsd_95_element_menclose
end
# <attributeGroup name="Table-alignment.attrib"/>
xsd_97_attributeGroup_Table_alignment_attrib = begin
  content = (Any)[]
  childcontent = xsd_97_attributeGroup_Table_alignment_attrib_1_optional
  content = [content, childcontent]
  childcontent = xsd_97_attributeGroup_Table_alignment_attrib_2_optional
  content = [content, childcontent]
  childcontent = xsd_97_attributeGroup_Table_alignment_attrib_3_optional
  content = [content, childcontent]
  content
end
# <attribute name="rowalign" default="baseline"/>
xsd_97_attributeGroup_Table_alignment_attrib_1_optional = begin
  choose(Bool) ? xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign : Any[]
end
# <attribute name="rowalign" default="baseline"/>
xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign = begin
  content = xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType
  @assert typeof(content)<:String
  ("rowalign", content)
end
# <simpleType/>
xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType = begin
  xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType_1_restriction = begin
  xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType_1_restriction_1_choice
end
xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType_1_restriction_1_choice = begin
  xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType_1_restriction_1_choice_1_pattern
end
# <pattern value="(top|bottom|center|baseline|axis)( top| bottom| center| baseline| axis)*"/>
xsd_97_attributeGroup_Table_alignment_attrib_1_optional_1_attribute_rowalign_1_simpleType_1_restriction_1_choice_1_pattern = begin
  choose(ASCIIString, "(top|bottom|center|baseline|axis)( top| bottom| center| baseline| axis)*")
end
# <attribute name="columnalign" default="center"/>
xsd_97_attributeGroup_Table_alignment_attrib_2_optional = begin
  choose(Bool) ? xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign : Any[]
end
# <attribute name="columnalign" default="center"/>
xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign = begin
  content = xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType
  @assert typeof(content)<:String
  ("columnalign", content)
end
# <simpleType/>
xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType = begin
  xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType_1_restriction = begin
  xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType_1_restriction_1_choice
end
xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType_1_restriction_1_choice = begin
  xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType_1_restriction_1_choice_1_pattern
end
# <pattern value="(left|center|right)( left| center| right)*"/>
xsd_97_attributeGroup_Table_alignment_attrib_2_optional_1_attribute_columnalign_1_simpleType_1_restriction_1_choice_1_pattern = begin
  choose(ASCIIString, "(left|center|right)( left| center| right)*")
end
# <attribute name="groupalign" type="xs:string"/>
xsd_97_attributeGroup_Table_alignment_attrib_3_optional = begin
  choose(Bool) ? xsd_97_attributeGroup_Table_alignment_attrib_3_optional_1_attribute_groupalign : Any[]
end
# <attribute name="groupalign" type="xs:string"/>
xsd_97_attributeGroup_Table_alignment_attrib_3_optional_1_attribute_groupalign = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("groupalign", content)
end
# <attributeGroup name="mtr.attlist"/>
xsd_98_attributeGroup_mtr_attlist = begin
  content = (Any)[]
  childcontent = xsd_97_attributeGroup_Table_alignment_attrib
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <group name="mtr.content"/>
xsd_99_group_mtr_content = begin
  content = (Any)[]
  childcontent = xsd_99_group_mtr_content_1_sequence
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_99_group_mtr_content_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_109_element_mtd
  content = [content, childcontent]
  content
end
# <complexType name="mtr.type"/>
xsd_100_complexType_mtr_type = begin
  content = (Any)[]
  childcontent = xsd_99_group_mtr_content
  content = [content, childcontent]
  childcontent = xsd_98_attributeGroup_mtr_attlist
  content = [content, childcontent]
  content
end
# <element name="mtr" type="mtr.type"/>
xsd_101_element_mtr = begin
  content = (Any)[]
  childcontent = xsd_100_complexType_mtr_type
  content = [content, childcontent]
  construct_element("mtr", content)
end
# <attributeGroup name="mlabeledtr.attlist"/>
xsd_102_attributeGroup_mlabeledtr_attlist = begin
  content = (Any)[]
  childcontent = xsd_97_attributeGroup_Table_alignment_attrib
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <group name="mlabeledtr.content"/>
xsd_103_group_mlabeledtr_content = begin
  content = (Any)[]
  childcontent = xsd_103_group_mlabeledtr_content_1_sequence
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_103_group_mlabeledtr_content_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_109_element_mtd
  content = [content, childcontent]
  content
end
# <complexType name="mlabeledtr.type"/>
xsd_104_complexType_mlabeledtr_type = begin
  content = (Any)[]
  childcontent = xsd_103_group_mlabeledtr_content
  content = [content, childcontent]
  childcontent = xsd_102_attributeGroup_mlabeledtr_attlist
  content = [content, childcontent]
  content
end
# <element name="mlabeledtr" type="mlabeledtr.type"/>
xsd_105_element_mlabeledtr = begin
  content = (Any)[]
  childcontent = xsd_104_complexType_mlabeledtr_type
  content = [content, childcontent]
  construct_element("mlabeledtr", content)
end
# <attributeGroup name="mtd.attlist"/>
xsd_106_attributeGroup_mtd_attlist = begin
  content = (Any)[]
  childcontent = xsd_97_attributeGroup_Table_alignment_attrib
  content = [content, childcontent]
  childcontent = xsd_106_attributeGroup_mtd_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="rowspan" default="1" type="xs:positiveInteger"/>
xsd_106_attributeGroup_mtd_attlist_2_optional = begin
  choose(Bool) ? xsd_106_attributeGroup_mtd_attlist_2_optional_1_attribute_rowspan : Any[]
end
# <attribute name="rowspan" default="1" type="xs:positiveInteger"/>
xsd_106_attributeGroup_mtd_attlist_2_optional_1_attribute_rowspan = begin
  content = xsd_136_simpleType_xs_positiveInteger
  @assert typeof(content)<:String
  ("rowspan", content)
end
# <group name="mtd.content"/>
xsd_107_group_mtd_content = begin
  content = (Any)[]
  childcontent = xsd_107_group_mtd_content_1_sequence
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_107_group_mtd_content_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  content
end
# <complexType name="mtd.type"/>
xsd_108_complexType_mtd_type = begin
  content = (Any)[]
  childcontent = xsd_107_group_mtd_content
  content = [content, childcontent]
  childcontent = xsd_106_attributeGroup_mtd_attlist
  content = [content, childcontent]
  content
end
# <element name="mtd" type="mtd.type"/>
xsd_109_element_mtd = begin
  content = (Any)[]
  childcontent = xsd_108_complexType_mtd_type
  content = [content, childcontent]
  construct_element("mtd", content)
end
# <attributeGroup name="mtable.attlist"/>
xsd_110_attributeGroup_mtable_attlist = begin
  content = (Any)[]
  childcontent = xsd_97_attributeGroup_Table_alignment_attrib
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_3_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_4_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_5_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_6_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_7_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_8_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_9_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_10_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_11_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_12_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_13_optional
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist_14_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="align" default="axis" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_2_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_2_optional_1_attribute_align : Any[]
end
# <attribute name="align" default="axis" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_2_optional_1_attribute_align = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("align", content)
end
# <attribute name="columnwidth" default="auto" type="domain-knowledge-length-with-unit-or-auto"/>
xsd_110_attributeGroup_mtable_attlist_3_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_3_optional_1_attribute_columnwidth : Any[]
end
# <attribute name="columnwidth" default="auto" type="domain-knowledge-length-with-unit-or-auto"/>
xsd_110_attributeGroup_mtable_attlist_3_optional_1_attribute_columnwidth = begin
  content = xsd_111_simpleType_domain_knowledge_length_with_unit_or_auto
  @assert typeof(content)<:String
  ("columnwidth", content)
end
# <attribute name="width" default="auto" type="domain-knowledge-length-with-unit-or-auto"/>
xsd_110_attributeGroup_mtable_attlist_4_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_4_optional_1_attribute_width : Any[]
end
# <attribute name="width" default="auto" type="domain-knowledge-length-with-unit-or-auto"/>
xsd_110_attributeGroup_mtable_attlist_4_optional_1_attribute_width = begin
  content = xsd_111_simpleType_domain_knowledge_length_with_unit_or_auto
  @assert typeof(content)<:String
  ("width", content)
end
# <attribute name="rowspacing" default="1.0ex" type="length-with-unit"/>
xsd_110_attributeGroup_mtable_attlist_5_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_5_optional_1_attribute_rowspacing : Any[]
end
# <attribute name="rowspacing" default="1.0ex" type="length-with-unit"/>
xsd_110_attributeGroup_mtable_attlist_5_optional_1_attribute_rowspacing = begin
  content = xsd_11_simpleType_length_with_unit
  @assert typeof(content)<:String
  ("rowspacing", content)
end
# <attribute name="columnspacing" default="0.8em" type="length-with-unit"/>
xsd_110_attributeGroup_mtable_attlist_6_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_6_optional_1_attribute_columnspacing : Any[]
end
# <attribute name="columnspacing" default="0.8em" type="length-with-unit"/>
xsd_110_attributeGroup_mtable_attlist_6_optional_1_attribute_columnspacing = begin
  content = xsd_11_simpleType_length_with_unit
  @assert typeof(content)<:String
  ("columnspacing", content)
end
# <attribute name="rowlines" default="none" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_7_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_7_optional_1_attribute_rowlines : Any[]
end
# <attribute name="rowlines" default="none" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_7_optional_1_attribute_rowlines = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("rowlines", content)
end
# <attribute name="columnlines" default="none" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_8_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_8_optional_1_attribute_columnlines : Any[]
end
# <attribute name="columnlines" default="none" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_8_optional_1_attribute_columnlines = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("columnlines", content)
end
# <attribute name="frame" default="none"/>
xsd_110_attributeGroup_mtable_attlist_9_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame : Any[]
end
# <attribute name="frame" default="none"/>
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame = begin
  content = xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType
  @assert typeof(content)<:String
  ("frame", content)
end
# <simpleType/>
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType = begin
  xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction = begin
  xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice
end
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice = begin
  xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice = begin
  xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice_2_enumeration
end
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice = begin
  xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice_3_enumeration
end
# <enumeration value="none"/>
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "none"
end
# <enumeration value="solid"/>
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "solid"
end
# <enumeration value="dashed"/>
xsd_110_attributeGroup_mtable_attlist_9_optional_1_attribute_frame_1_simpleType_1_restriction_1_choice_3_enumeration = begin
  "dashed"
end
# <attribute name="framespacing" default="0.4em 0.5ex" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_10_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_10_optional_1_attribute_framespacing : Any[]
end
# <attribute name="framespacing" default="0.4em 0.5ex" type="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_10_optional_1_attribute_framespacing = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("framespacing", content)
end
# <attribute name="equalrows" default="false" type="xs:boolean"/>
xsd_110_attributeGroup_mtable_attlist_11_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_11_optional_1_attribute_equalrows : Any[]
end
# <attribute name="equalrows" default="false" type="xs:boolean"/>
xsd_110_attributeGroup_mtable_attlist_11_optional_1_attribute_equalrows = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("equalrows", content)
end
# <attribute name="equalcolumns" default="false" type="xs:boolean"/>
xsd_110_attributeGroup_mtable_attlist_12_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_12_optional_1_attribute_equalcolumns : Any[]
end
# <attribute name="equalcolumns" default="false" type="xs:boolean"/>
xsd_110_attributeGroup_mtable_attlist_12_optional_1_attribute_equalcolumns = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("equalcolumns", content)
end
# <attribute name="displaystyle" default="false" type="xs:boolean"/>
xsd_110_attributeGroup_mtable_attlist_13_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_13_optional_1_attribute_displaystyle : Any[]
end
# <attribute name="displaystyle" default="false" type="xs:boolean"/>
xsd_110_attributeGroup_mtable_attlist_13_optional_1_attribute_displaystyle = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("displaystyle", content)
end
# <attribute name="side" default="right"/>
xsd_110_attributeGroup_mtable_attlist_14_optional = begin
  choose(Bool) ? xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side : Any[]
end
# <attribute name="side" default="right"/>
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side = begin
  content = xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType
  @assert typeof(content)<:String
  ("side", content)
end
# <simpleType/>
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType = begin
  xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction = begin
  xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice
end
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice = begin
  xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice = begin
  xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_2_enumeration
end
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice = begin
  xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_3_enumeration
end
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice = begin
  xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_4_enumeration
end
# <enumeration value="left"/>
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "left"
end
# <enumeration value="right"/>
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "right"
end
# <enumeration value="leftoverlap"/>
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_3_enumeration = begin
  "leftoverlap"
end
# <enumeration value="rightoverlap"/>
xsd_110_attributeGroup_mtable_attlist_14_optional_1_attribute_side_1_simpleType_1_restriction_1_choice_4_enumeration = begin
  "rightoverlap"
end
# <simpleType name="domain-knowledge-length-with-unit-or-auto"/>
xsd_111_simpleType_domain_knowledge_length_with_unit_or_auto = begin
  xsd_111_simpleType_domain_knowledge_length_with_unit_or_auto_1_union
end
# <union memberTypes="length-with-unit domain-knowledge-auto"/>
xsd_111_simpleType_domain_knowledge_length_with_unit_or_auto_1_union = begin
  xsd_11_simpleType_length_with_unit
end
# <union memberTypes="length-with-unit domain-knowledge-auto"/>
xsd_111_simpleType_domain_knowledge_length_with_unit_or_auto_1_union = begin
  xsd_112_simpleType_domain_knowledge_auto
end
# <simpleType name="domain-knowledge-auto"/>
xsd_112_simpleType_domain_knowledge_auto = begin
  xsd_112_simpleType_domain_knowledge_auto_1_restriction
end
# <restriction base="xs:string"/>
xsd_112_simpleType_domain_knowledge_auto_1_restriction = begin
  xsd_112_simpleType_domain_knowledge_auto_1_restriction_1_choice
end
xsd_112_simpleType_domain_knowledge_auto_1_restriction_1_choice = begin
  xsd_112_simpleType_domain_knowledge_auto_1_restriction_1_choice_1_enumeration
end
# <enumeration value="auto"/>
xsd_112_simpleType_domain_knowledge_auto_1_restriction_1_choice_1_enumeration = begin
  "auto"
end
# <group name="mtable.content"/>
xsd_113_group_mtable_content = begin
  content = (Any)[]
  childcontent = xsd_113_group_mtable_content_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_113_group_mtable_content_1_choice = begin
  xsd_101_element_mtr
end
# <choice/>
xsd_113_group_mtable_content_1_choice = begin
  xsd_105_element_mlabeledtr
end
# <complexType name="mtable.type"/>
xsd_114_complexType_mtable_type = begin
  content = (Any)[]
  childcontent = xsd_113_group_mtable_content
  content = [content, childcontent]
  childcontent = xsd_110_attributeGroup_mtable_attlist
  content = [content, childcontent]
  content
end
# <element name="mtable" type="mtable.type"/>
xsd_115_element_mtable = begin
  content = (Any)[]
  childcontent = xsd_114_complexType_mtable_type
  content = [content, childcontent]
  construct_element("mtable", content)
end
# <attributeGroup name="maligngroup.attlist"/>
xsd_116_attributeGroup_maligngroup_attlist = begin
  content = (Any)[]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <complexType name="maligngroup.type"/>
xsd_117_complexType_maligngroup_type = begin
  content = (Any)[]
  childcontent = xsd_116_attributeGroup_maligngroup_attlist
  content = [content, childcontent]
  content
end
# <element name="maligngroup" type="maligngroup.type"/>
xsd_118_element_maligngroup = begin
  content = (Any)[]
  childcontent = xsd_117_complexType_maligngroup_type
  content = [content, childcontent]
  construct_element("maligngroup", content)
end
# <attributeGroup name="malignmark.attlist"/>
xsd_119_attributeGroup_malignmark_attlist = begin
  content = (Any)[]
  childcontent = xsd_119_attributeGroup_malignmark_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="edge" default="left"/>
xsd_119_attributeGroup_malignmark_attlist_1_optional = begin
  choose(Bool) ? xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge : Any[]
end
# <attribute name="edge" default="left"/>
xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge = begin
  content = xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType
  @assert typeof(content)<:String
  ("edge", content)
end
# <simpleType/>
xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType = begin
  xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction
end
# <restriction base="xs:string"/>
xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction = begin
  xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction_1_choice
end
xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction_1_choice = begin
  xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction_1_choice_1_enumeration
end
xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction_1_choice = begin
  xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction_1_choice_2_enumeration
end
# <enumeration value="left"/>
xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction_1_choice_1_enumeration = begin
  "left"
end
# <enumeration value="right"/>
xsd_119_attributeGroup_malignmark_attlist_1_optional_1_attribute_edge_1_simpleType_1_restriction_1_choice_2_enumeration = begin
  "right"
end
# <complexType name="malignmark.type"/>
xsd_120_complexType_malignmark_type = begin
  content = (Any)[]
  childcontent = xsd_119_attributeGroup_malignmark_attlist
  content = [content, childcontent]
  content
end
# <element name="malignmark" type="malignmark.type"/>
xsd_121_element_malignmark = begin
  content = (Any)[]
  childcontent = xsd_120_complexType_malignmark_type
  content = [content, childcontent]
  construct_element("malignmark", content)
end
# <group name="Presentation-table.class"/>
xsd_122_group_Presentation_table_class = begin
  content = (Any)[]
  childcontent = xsd_122_group_Presentation_table_class_1_choice
  content = [content, childcontent]
  content
end
# <choice/>
xsd_122_group_Presentation_table_class_1_choice = begin
  xsd_115_element_mtable
end
# <choice/>
xsd_122_group_Presentation_table_class_1_choice = begin
  xsd_118_element_maligngroup
end
# <choice/>
xsd_122_group_Presentation_table_class_1_choice = begin
  xsd_121_element_malignmark
end
# <attributeGroup name="mstyle.attlist"/>
xsd_123_attributeGroup_mstyle_attlist = begin
  content = (Any)[]
  childcontent = xsd_123_attributeGroup_mstyle_attlist_1_optional
  content = [content, childcontent]
  childcontent = xsd_123_attributeGroup_mstyle_attlist_2_optional
  content = [content, childcontent]
  childcontent = xsd_123_attributeGroup_mstyle_attlist_3_optional
  content = [content, childcontent]
  childcontent = xsd_123_attributeGroup_mstyle_attlist_4_optional
  content = [content, childcontent]
  childcontent = xsd_123_attributeGroup_mstyle_attlist_5_optional
  content = [content, childcontent]
  childcontent = xsd_123_attributeGroup_mstyle_attlist_6_optional
  content = [content, childcontent]
  childcontent = xsd_18_attributeGroup_Operator_attrib
  content = [content, childcontent]
  childcontent = xsd_15_attributeGroup_Token_style_attrib
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="scriptlevel" type="xs:integer"/>
xsd_123_attributeGroup_mstyle_attlist_1_optional = begin
  choose(Bool) ? xsd_123_attributeGroup_mstyle_attlist_1_optional_1_attribute_scriptlevel : Any[]
end
# <attribute name="scriptlevel" type="xs:integer"/>
xsd_123_attributeGroup_mstyle_attlist_1_optional_1_attribute_scriptlevel = begin
  content = xsd_137_simpleType_xs_integer
  @assert typeof(content)<:String
  ("scriptlevel", content)
end
# <attribute name="displaystyle" type="xs:boolean"/>
xsd_123_attributeGroup_mstyle_attlist_2_optional = begin
  choose(Bool) ? xsd_123_attributeGroup_mstyle_attlist_2_optional_1_attribute_displaystyle : Any[]
end
# <attribute name="displaystyle" type="xs:boolean"/>
xsd_123_attributeGroup_mstyle_attlist_2_optional_1_attribute_displaystyle = begin
  content = xsd_134_simpleType_xs_boolean
  @assert typeof(content)<:String
  ("displaystyle", content)
end
# <attribute name="scriptminsize" default="8pt" type="length-with-unit"/>
xsd_123_attributeGroup_mstyle_attlist_3_optional = begin
  choose(Bool) ? xsd_123_attributeGroup_mstyle_attlist_3_optional_1_attribute_scriptminsize : Any[]
end
# <attribute name="scriptminsize" default="8pt" type="length-with-unit"/>
xsd_123_attributeGroup_mstyle_attlist_3_optional_1_attribute_scriptminsize = begin
  content = xsd_11_simpleType_length_with_unit
  @assert typeof(content)<:String
  ("scriptminsize", content)
end
# <attribute name="color" type="xs:string"/>
xsd_123_attributeGroup_mstyle_attlist_4_optional = begin
  choose(Bool) ? xsd_123_attributeGroup_mstyle_attlist_4_optional_1_attribute_color : Any[]
end
# <attribute name="color" type="xs:string"/>
xsd_123_attributeGroup_mstyle_attlist_4_optional_1_attribute_color = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("color", content)
end
# <attribute name="background" default="transparent" type="xs:string"/>
xsd_123_attributeGroup_mstyle_attlist_5_optional = begin
  choose(Bool) ? xsd_123_attributeGroup_mstyle_attlist_5_optional_1_attribute_background : Any[]
end
# <attribute name="background" default="transparent" type="xs:string"/>
xsd_123_attributeGroup_mstyle_attlist_5_optional_1_attribute_background = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("background", content)
end
# <attribute name="linethickness" default="1"/>
xsd_123_attributeGroup_mstyle_attlist_6_optional = begin
  choose(Bool) ? xsd_123_attributeGroup_mstyle_attlist_6_optional_1_attribute_linethickness : Any[]
end
# <attribute name="linethickness" default="1"/>
xsd_123_attributeGroup_mstyle_attlist_6_optional_1_attribute_linethickness = begin
  content = xsd_123_attributeGroup_mstyle_attlist_6_optional_1_attribute_linethickness_1_simpleType
  @assert typeof(content)<:String
  ("linethickness", content)
end
# <simpleType/>
xsd_123_attributeGroup_mstyle_attlist_6_optional_1_attribute_linethickness_1_simpleType = begin
  xsd_123_attributeGroup_mstyle_attlist_6_optional_1_attribute_linethickness_1_simpleType_1_union
end
# <union memberTypes="length-with-optional-unit thickness"/>
xsd_123_attributeGroup_mstyle_attlist_6_optional_1_attribute_linethickness_1_simpleType_1_union = begin
  xsd_12_simpleType_length_with_optional_unit
end
# <union memberTypes="length-with-optional-unit thickness"/>
xsd_123_attributeGroup_mstyle_attlist_6_optional_1_attribute_linethickness_1_simpleType_1_union = begin
  xsd_10_simpleType_thickness
end
# <group name="mstyle.content"/>
xsd_124_group_mstyle_content = begin
  content = (Any)[]
  childcontent = xsd_124_group_mstyle_content_1_sequence
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_124_group_mstyle_content_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  content
end
# <complexType name="mstyle.type"/>
xsd_125_complexType_mstyle_type = begin
  content = (Any)[]
  childcontent = xsd_124_group_mstyle_content
  content = [content, childcontent]
  childcontent = xsd_123_attributeGroup_mstyle_attlist
  content = [content, childcontent]
  content
end
# <element name="mstyle" type="mstyle.type"/>
xsd_126_element_mstyle = begin
  content = (Any)[]
  childcontent = xsd_125_complexType_mstyle_type
  content = [content, childcontent]
  construct_element("mstyle", content)
end
# <attributeGroup name="maction.attlist"/>
xsd_127_attributeGroup_maction_attlist = begin
  content = (Any)[]
  childcontent = xsd_127_attributeGroup_maction_attlist_1_attribute_actiontype
  content = [content, childcontent]
  childcontent = xsd_7_attributeGroup_Common_attrib
  content = [content, childcontent]
  content
end
# <attribute name="actiontype" use="required" type="xs:string"/>
xsd_127_attributeGroup_maction_attlist_1_attribute_actiontype = begin
  content = xsd_131_simpleType_xs_string
  @assert typeof(content)<:String
  ("actiontype", content)
end
# <group name="maction.content"/>
xsd_128_group_maction_content = begin
  content = (Any)[]
  childcontent = xsd_128_group_maction_content_1_sequence
  content = [content, childcontent]
  content
end
# <sequence/>
xsd_128_group_maction_content_1_sequence = begin
  content = (Any)[]
  childcontent = xsd_1_group_Presentation_expr_class
  content = [content, childcontent]
  content
end
# <complexType name="maction.type"/>
xsd_129_complexType_maction_type = begin
  content = (Any)[]
  childcontent = xsd_128_group_maction_content
  content = [content, childcontent]
  childcontent = xsd_127_attributeGroup_maction_attlist
  content = [content, childcontent]
  content
end
# <element name="maction" type="maction.type"/>
xsd_130_element_maction = begin
  content = (Any)[]
  childcontent = xsd_129_complexType_maction_type
  content = [content, childcontent]
  construct_element("maction", content)
end
xsd_131_simpleType_xs_string = begin
  xsd_131_simpleType_xs_string_1_pattern
end
xsd_131_simpleType_xs_string_1_pattern = begin
  choose(ASCIIString, "")
end
xsd_132_simpleType_xs_NMTOKENS = begin
  xsd_132_simpleType_xs_NMTOKENS_1_pattern
end
xsd_132_simpleType_xs_NMTOKENS_1_pattern = begin
  choose(ASCIIString, "\\c+(, \\c+)*")
end
xsd_133_simpleType_xs_ID = begin
  # warn("uniqueness of xs:ID not enforced in xsd_133_simpleType_xs_ID")
  xsd_133_simpleType_xs_ID_1_pattern
end
xsd_133_simpleType_xs_ID_1_pattern = begin
  choose(ASCIIString, "\\i\\c*")
end
xsd_134_simpleType_xs_boolean = begin
  xsd_134_simpleType_xs_boolean_1_pattern
end
xsd_134_simpleType_xs_boolean_1_pattern = begin
  choose(ASCIIString, "true|false")
end
xsd_135_simpleType_xs_float = begin
  xsd_135_simpleType_xs_float_1_pattern
end
xsd_135_simpleType_xs_float_1_pattern = begin
  choose(ASCIIString, "[+-]?([0-9]+|[0-9]*.[0-9]+)(E[+-]?[0-9]+)?|INF|-INF|NaN")
end
xsd_136_simpleType_xs_positiveInteger = begin
  xsd_136_simpleType_xs_positiveInteger_1_pattern
end
xsd_136_simpleType_xs_positiveInteger_1_pattern = begin
  choose(ASCIIString, "\\+?0+[1-9][0-9]+")
end
xsd_137_simpleType_xs_integer = begin
  xsd_137_simpleType_xs_integer_1_pattern
end
xsd_137_simpleType_xs_integer_1_pattern = begin
  choose(ASCIIString, "[+-]?[0-9]+")
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
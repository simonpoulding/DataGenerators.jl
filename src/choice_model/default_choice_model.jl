# A default choice model which can be used mostly for testing purposes. It just falls back on the
# default implementations of the interface.
# In practice the choice model will typically/always need to be tuned to the specific generator
# for it to be useful.
type DefaultChoiceModel <: ChoiceModel; end
	
# for consistency with other choice models, constructor that is passed a generator instance
# here nothing is done
function DefaultChoiceModel(g::Generator)
	DefaultChoiceModel()
end

#
# The godelnumber function is the interface to all subtypes of ChoiceModel. Override to implement more specific
# behavior.
#
# Guarentees made by DataGenerators to the choice model:
#
#	 (1) ChoiceContext.lowerbound <= ChoiceContext.upperbound
#	 (2) ChoiceContext.lowerbound and upperbound have the type ChoiceContext.datatype (for integer datatypes this means
#      that full range is indicated by bounds of typemin and typemax rather than -Inf and Inf)
#
# Assumptions made by DataGenerators on value return by the choice model:
#
#  (1) must be between ChoiceContext.lowerbound and ChoiceContext.upperbound (inclusive)
#  (2) must be convertible without loss of precision to ChoiceContext.datatype (i.e. does not cause convert to raise an
#      InexactError), but need not be of the specified datatype
#
function godelnumber(cm::DefaultChoiceModel, cc::ChoiceContext)
	# finitise infinities to maxintfloat()/10 (approx 9e14 for Float64)
	# using a range that has a size that is less than maxintfloat ensures that the range is small enough that some of the Godel numbers
	# are, after conversion back to the datatype, have a non-zero floating point part
	lowerbound = isfinite(cc.lowerbound) ? cc.lowerbound : sign(cc.lowerbound) * maxintfloat(cc.datatype) / 10
	upperbound = isfinite(cc.upperbound) ? cc.upperbound : sign(cc.upperbound) * maxintfloat(cc.datatype) / 10
	rangelen = convert(Float64,upperbound) - convert(Float64,lowerbound)
	if cc.datatype <: Integer
		rangelen += 1.0 # since the random value will be later floor'ed
	end
	if cc.cptype == SEQUENCE_CP
		# Default is to use maxReps of max 2 regardless of what the actual max is 
		# This is to limit the size of generated data for recursively defined generators.
		rangelen = min(rangelen, 3.0) # 3 because 1 is added to the rangelen above
	end
	gn = lowerbound + rand() * rangelen # note rand() returns a value in [0,1)
	if cc.datatype <: Integer
		gn = floor(gn)
		# note that query_choice_model will convert to the appropriate type, so need to use int() nor convert() here
	end
	gn, Dict()
end


#
# The following functions are used to set and get the parameters to the model (e.g. to enable optimisation)
# Currently the parameters are assumed to be Real numbers
#

# valid ranges for each parameter, return as a vector; each range is a tuple (min,max) where (ironically, given the notation)
# values are inclusive
paramranges(cm::DefaultChoiceModel) = Tuple{Real,Real}[]

# set parameters using the passed vector of values
setparams(cm::DefaultChoiceModel, params) = nothing

# get parameters as a vector of values
getparams(cm::DefaultChoiceModel) = Real[]


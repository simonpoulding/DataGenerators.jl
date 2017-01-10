using DataGenerators
using Base.Test

include("test_utilities.jl")

println("Creating type generator")

typeg = create_generator("TypeGen", Type, Type[Number;])

typegi = typeg()

for i in 1:100

	t = nothing
	while t == nothing
		try
			t = choose(typegi)
			if t == Union{}
				warn("skipping type returned from type generator as it is Union{}")
				t = nothing
				continue
			end
		catch exc
			if isa(exc, DataGenerators.TypeGenerationException)
				warn("skipping type returned from type generator owing to: $(exc)")
				continue
			else
				rethrow(exc)
			end
		end
	end

	try_generating_for_type(t, DataGenerators.GENERATOR_SUPPORTED_CHOOSE_TYPES, showdatum=false, showerror=false)

end
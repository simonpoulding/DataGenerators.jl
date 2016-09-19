function try_generating_for_type(t::Type, supplementalts::Vector{Type} = Vector{Type}(); tries::Int = 100, showdatum::Bool=false, showerror::Bool=false)

	println("type $(t):")

	g = type_generator(:TypeGen, t, supplementalts)

	gi = g()

	print("  generating $(tries) data")
	if showdatum
		println()
	end

	for i in 1:100

		x = try 
			choose(gi)
		catch exc
			if isa(exc, DataGenerators.TypeGenerationException)
				if showerror
					warn("$(exc)")
				else
					print("!")
				end
				continue
			else
				rethrow(exc)
			end
		end

		if showdatum
			println("Type $(typeof(x)); Value: $(x)")
		else
			print(".")
		end

		@test DataGenerators.isa_tuple_adjust(x, t)

	end
	println()

	println()
	
end
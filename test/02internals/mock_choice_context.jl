if !isdefined(:mockCC)
  # dummy ChoiceContext to test godelnumber functions
  type MockDS <: GodelTest.DerivationState; end
	function mockCC(lowerbound = 0.0, upperbound = 1e7, datatype = Float64, cptype = GodelTest.VALUE_CP, cpid = 1)
  	GodelTest.ChoiceContext(MockDS(), cptype, cpid, datatype, lowerbound, upperbound)
	end
end

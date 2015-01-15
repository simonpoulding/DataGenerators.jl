if !isdefined(:MockCC)
  # We need dummy ChoiceContext to test godelnumber.
  type MockDS <: GodelTest.DerivationState; end
  MockCC = GodelTest.ChoiceContext(MockDS(), :d, 1, Float64, 0.0, 1e7)
end

using GodelTest: TransformingFuncSampler, GaussianSampler, godelnumber, setparams, getparams, numparams, paramranges

include("mock_choice_context.jl")

describe("TransformingFuncSampler") do

  GSTypical = GaussianSampler(0.0, 100.0, 10.0)
  TFS = TransformingFuncSampler(GSTypical, (gn::Number) -> abs(gn)::Number)

  @repeat test("methods are just deferred down to the subsampler") do
    newparams = [rand(0.0:100.0), rand(0.1:10.0)]
    setparams(TFS, newparams)
    @check getparams(TFS) == newparams
    @check numparams(TFS) == numparams(GSTypical)
    @check paramranges(TFS) == paramranges(GSTypical)
  end

  @repeat test("generates floating point godel numbers that are in valid range even if params outside of valid range") do
    setparams(TFS, [rand(-10.0:100.0), rand(-10.0:10.0)])
    gnum = godelnumber(TFS, mockCC())
    @check typeof(gnum) <: FloatingPoint
    @check 0.0 <= gnum <= (100.0 + 8*10.0)
  end

end

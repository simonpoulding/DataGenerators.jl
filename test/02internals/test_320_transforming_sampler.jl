using GodelTest: TransformingFuncSampler, GaussianSampler, godelnumber, setparams, getparams, numparams, paramranges

include("mock_choice_context.jl")

describe("TransformingFuncSampler") do

  GSTypical = GaussianSampler()
  TFS = TransformingFuncSampler(GSTypical, (gn::Number) -> abs(gn)::Number)

  @repeat test("methods are just deferred down to the subsampler") do
    newparams = [rand(0.0:100.0), rand(0.1:10.0)]
    setparams(TFS, newparams)
    @check getparams(TFS) == newparams
    @check numparams(TFS) == numparams(GSTypical)
    @check paramranges(TFS) == paramranges(GSTypical)
  end

  cc = mockCC(-Inf,Inf,Float64)
  @repeat test("transformation is applied") do
    setparams(TFS, [rand(-100.0:100.0), rand(0.0:10.0)])
    gnum = godelnumber(TFS, cc)
    @check typeof(gnum) <: Float64
    @check 0.0 <= gnum <= (100.0 + 8*10.0)
  end

end

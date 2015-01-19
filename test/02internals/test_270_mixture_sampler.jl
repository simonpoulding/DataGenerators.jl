using GodelTest: MixtureSampler, GaussianSampler, Sampler, numparams, godelnumber, setparams, getparams

include("mock_choice_context.jl")

describe("MixtureSampler") do

  Gs1 = GaussianSampler(0.0, 100.0, 2.0)
  Gs1SampleMin = 0.0 - 8*2.0
  Gs1SampleMax = 100.0 + 8*2.0

  Gs2 = GaussianSampler(1e3, 1e4, 2.0)
  Gs2SampleMin = 1e3 - 8*2.0
  Gs2SampleMax = 1e4 + 8*2.0

  Ms = MixtureSampler([Gs1, Gs2])

  test("constructor - from two gaussian samplers with very different ranges") do
    @check typeof(Ms) <: Sampler
    @check numparams(Ms) == (2 + 2 + 2) # 2 params for the categories and then 2 per Gaussian sampler
  end

  test("setparams and getparams") do
    newparams = Float64[0.5, 0.5, 0.0, 2.0, 1e3, 2.0]
    setparams(Ms, newparams)
    @check getparams(Ms) == newparams
  end

  @repeat test("samples from either of the two gaussian subsamplers") do
    setparams(Ms, Float64[0.5, 0.5, 0.0, 2.0, 1e3, 2.0])
    gnum = godelnumber(Ms, mockCC())
    # It must be from either of the two allowed ranges. We can use max of the one
    # giving smallest numbers to know which one it is.
    local sampler
    if gnum > Gs1SampleMax
      sampler = 2
      @check Gs2SampleMin <= gnum <= Gs2SampleMax
    else
      sampler = 1
      @check Gs1SampleMin <= gnum <= Gs1SampleMax
    end
    @mcheck_values_are sampler [1,2]
  end

end

using GodelTest: GaussianSampler, paramranges, godelnumber, setparams, getparams

include("mock_choice_context.jl")

describe("GaussianSampler") do

  test("constructor sets up paramranges correctly - concrete examples") do
    gs1 = GaussianSampler(0.0, 100.0, 10.0)
    @check paramranges(gs1) == [(0.0, 100.0), (0.0, 10.0)]

    gs2 = GaussianSampler(-10.0, 42.17, -10.0)
    @check paramranges(gs2)[1] == (-10.0, 42.17)
    @check paramranges(gs2)[2][1] == 0.0
    @check paramranges(gs2)[2][2] > 0.0
  end

  @repeat test("constructor sets up paramranges correctly - random testing") do
    minmean = rand(-1e2:1e3)
    maxmean = rand(-1e2:1e3)
    maxsigma = rand(-1e2:1e3)
    gs = GaussianSampler(minmean, maxmean, maxsigma)

    @check paramranges(gs)[1][1] >= minmean
    @check paramranges(gs)[1][2] >= paramranges(gs)[1][1]

    @check paramranges(gs)[2][1] == 0.0
    @check paramranges(gs)[2][2] >  0.0
  end

  GSTypical = GaussianSampler(0.0, 100.0, 10.0)

  @repeat test("setparams and getparams") do
    newparams = [rand(0.0:100.0), rand(0.1:10.0)]
    setparams(GSTypical, newparams)
    @check getparams(GSTypical) == newparams
  end

  # To get the expected min and max values when sampling this sampler
  # we run this code offline:
  # using Distributions
  # NumSamples = int(1e8)
  # mind = Normal(0.0, 10.0)
  # GSTypical_min = minimum([rand(mind) for i in 1:NumSamples]) # -65.17
  GSTypical_min = -66.0
  # maxd = Normal(100.0, 10.0)
  # GSTypical_max = maximum([rand(maxd) for i in 1:NumSamples]) # 156.06294945635256
  GSTypical_max = 156.5

  @repeat test("generates floating point godel numbers that are in valid range even if params outside of valid range") do
    setparams(GSTypical, [rand(-10.0:100.0), rand(-10.0:10.0)])
    gnum = godelnumber(GSTypical, MockCC)
    @check typeof(gnum) <: FloatingPoint
    @check GSTypical_min <= gnum <= GSTypical_max
  end

  GSTypicalInt = GaussianSampler(0.0, 100.0, 10.0, true)

  @repeat test("generates int godel numbers that are in valid range even if params outside of valid range") do
    setparams(GSTypicalInt, [rand(-10.0:100.0), rand(-10.0:10.0)])
    gnum = godelnumber(GSTypicalInt, MockCC)
    @check typeof(gnum) <: Integer
    @check typeof(gnum) == Int64
    @check GSTypical_min <= gnum <= GSTypical_max
  end

end

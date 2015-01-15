using GodelTest: CategoricalSampler, numparams, godelnumber, setparams, getparams

include("mock_choice_context.jl")

describe("CategoricalSampler") do

  Cs1 = CategoricalSampler(2)
  setparams(Cs1, [0.5, 0.5])

  test("constructor") do
    @check numparams(Cs1) == 2
    @check getparams(Cs1) == [0.5, 0.5]
  end

  @repeat test("generates valid godel numbers") do
    @mcheck_values_are godelnumber(Cs1, MockCC) [0, 1]
  end

  @repeat test("generates valid godel numbers even with random params") do
    p = rand()
    setparams(Cs1, [p, 1.0-p])
    for i in 1:100
      @mcheck_values_are godelnumber(Cs1, MockCC) [0, 1]
    end
  end

  @repeat test("generates valid godel numbers even with random, possibly invalid params") do
    setparams(Cs1, [rand(), rand()])
    for i in 1:100
      @mcheck_values_are godelnumber(Cs1, MockCC) [0, 1]
    end
  end
end
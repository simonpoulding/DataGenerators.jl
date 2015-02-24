using GodelTest

@generator GenOutsideModule begin
  start() = choose(Int, 1, 10)
end

module GenDefinedInModuleThatIncludesGodelTest
  using GodelTest

  @generator TestGen begin
    start() = choose(Int, 1, 5)
  end
end

#module GenDefinedInModuleWithoutIncludingGodelTest
#  GodelTest.@generator TestGen begin
#    start() = choose(Float64, 0.0, 5.0)
#  end
#end

describe("generator defined outside of a module") do
  @repeat test("use generator defined outside module") do
    g = GenOutsideModule()
    @check typeof(g) <: GodelTest.Generator
    @check typeof(gen(g)) <: Integer
  end
end

describe("generator defined in a module") do
  test("use Int generator (defined in module which includes GodelTest) outside of module") do
    g = GenDefinedInModuleThatIncludesGodelTest.TestGen()
    @check typeof(g) <: GodelTest.Generator
    d = gen(g)
    @check typeof(d) <: Int
  end
end
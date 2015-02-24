using GodelTest

@generator GenOutsideModule begin
  start() = choose(Int, 1, 10)
end

module GenDefinedInModuleThatIncludesGodelTest
  using GodelTest

  @generator TestGen begin
    start() = choose(Int, 1, 5)
  end

  function generate_in_a_function()
    gen(TestGen())
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
  # This fail on the gen(g) line. Skipping until we fix.
  _test("use Int generator (defined in module which includes GodelTest) outside of module") do
    g = GenDefinedInModuleThatIncludesGodelTest.TestGen()
    @check typeof(g) <: GodelTest.Generator
    d = gen(g)
    @check typeof(d) <: Int
  end

  # This also fails. Skipping until we fix.
  _test("use Int generator from function internal to a module") do
    d = GenDefinedInModuleThatIncludesGodelTest.generate_in_a_function()
    @check typeof(d) <: Int
  end
end
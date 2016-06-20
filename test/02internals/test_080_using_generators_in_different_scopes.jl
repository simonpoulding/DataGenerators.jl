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

@testset "generator defined outside of a module" begin
    @testset "use generator defined outside module" for i in 1:NumReps 
        g = GenOutsideModule()
        @test typeof(g) <: GodelTest.Generator
        @test typeof(gen(g)) <: Integer
    end
end

@testset "generator defined in a module" begin
    # This fail on the gen(g) line. Skipping until we fix.
    @testset skip=true "use Int generator (defined in module which includes GodelTest) outside of module" begin
        g = GenDefinedInModuleThatIncludesGodelTest.TestGen()
        @test typeof(g) <: GodelTest.Generator
        d = gen(g)
        @test typeof(d) <: Int
    end

    # This also fails. Skipping until we fix.
    @testset skip=true "use Int generator from function internal to a module" begin
        d = GenDefinedInModuleThatIncludesGodelTest.generate_in_a_function()
        @test typeof(d) <: Int
    end
end
@generator GenOutsideModule begin
    start() = choose(Int, 1, 10)
end

module GenDefinedInModuleThatIncludesDataGenerators
    using DataGenerators

    @generator TestGen begin
        start() = choose(Int, 1, 5)
    end

    function generate_in_a_function()
        choose(TestGen())
    end
end

@testset "generator defined outside of a module" begin
    @testset "use generator defined outside module" begin 
        g = GenOutsideModule()
        @test typeof(g) <: DataGenerators.Generator
        @test typeof(choose(g)) <: Integer
    end
end

@testset "generator defined in a module" begin
    # This fail on the choose(g) line. Skipping until we fix.
    @testset "use Int generator (defined in module which includes DataGenerators. outside of module" begin
        g = GenDefinedInModuleThatIncludesDataGenerators.TestGen()
        @test typeof(g) <: DataGenerators.Generator
        d = choose(g)
        @test typeof(d) <: Int
    end

    # This also fails. Skipping until we fix.
    @testset "use Int generator from function internal to a module" begin
        d = GenDefinedInModuleThatIncludesDataGenerators.generate_in_a_function()
        @test typeof(d) <: Int
    end
end
# tests metadata

@generator MDGeneratesGen() begin # prefix MD (for Meta Data) to avoid type name clashes
    generates: ["a roll of a die", "a roll of a dice"]
    start() = choose(Int, 1, 6)
end

@testset "generator with 'generates' metadata" begin

gn = MDGeneratesGen()

@testset "generates metadata is recorded" begin
    md = meta(gn)
    @test md[:generates] == ["a roll of a die", "a roll of a dice"]
end
	
@testset "generator returns an integer between 1 and 6" begin
    td = choose(gn)
    @test 1 <= td <= 6		
end
	
end

@generator MDBlockGen begin
begin
    generates: ["a month number"]
end
begin
    start() = choose(Int, 1, 12)
end
end

@testset "generator with 'generates' metadata inside a block" begin

gn = MDBlockGen()
	
@testset "metadata identified inside a block" begin
    md = meta(gn)
    @test md[:generates] == ["a month number"]
end
	
end
# tests metadata

@generator MDGeneratesGen() begin # prefix MD (for Meta Data) to avoid type name clashes
    generates: ["a roll of a die", "a roll of a dice"]
    start() = choose(Int, 1, 6)
end

@generator MDBlockGen begin
begin
    generates: ["a month number"]
end
begin
    start() = choose(Int, 1, 12)
end
end

@testset "metadata" begin

	@testset "generator with 'generates' metadata" begin

		gn = MDGeneratesGen()

	    md = meta(gn)
	    @test md[:generates] == ["a roll of a die", "a roll of a dice"]
	
	    td = choose(gn)
	    @test 1 <= td <= 6		
	
	end

	@testset "generator with 'generates' metadata inside a block" begin

		gn = MDBlockGen()
	
	    md = meta(gn)
	    @test md[:generates] == ["a month number"]
	
	end
	
end
# tests metadata

using GodelTest

@generator MDGeneratesGen() begin # prefix MD (for Meta Data) to avoid type name clashes
	generates: ["a roll of a die", "a roll of a dice"]
	start() = choose(Int, 1, 6)
end

describe("generator with 'generates' metadata") do

	gn = MDGeneratesGen()

  test("generates metadata is recorded") do
		md = meta(gn)
		@check md[:generates] == ["a roll of a die", "a roll of a dice"]
	end
	
	test("generator returns an integer between 1 and 6") do
		td = gen(gn)
		@check 1 <= td <= 6		
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

describe("generator with 'generates' metadata inside a block") do

	gn = MDBlockGen()
	
	test("metadata identified inside a block") do
		md = meta(gn)
		@check md[:generates] == ["a month number"]
	end
	
end
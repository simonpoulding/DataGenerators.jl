# tests rule choice points

using GodelTest


# basic reps choice point

@generator RCShortGen begin # prefix RC (for Rule Choice points) to avoid type name clashes
	start() = x()
	x() = 'a'
	x() = 'b'
	x() = 'c'
end

describe("rule choice point using short form function definitions") do

	gn = RCShortGen()

  @repeat test("returns 'a' or 'b' or 'c'") do
		td = gen(gn)
		@mcheck_values_are td ['a','b','c']
	end

end


@generator RCLongGen begin
	start() = x()
	function x()
		'a'
	end
	function x()
		'b'
	end
	function x()
		'c'
	end
end

describe("rule choice point using long form function definitions") do

	gn = RCLongGen()

  @repeat test("returns 'a' or 'b' or 'c'") do
		td = gen(gn)
		@mcheck_values_are td ['a','b','c']
	end
	
end


@generator RCMixedGen begin
	start() = x()
	x() = 'a'
	function x()
		'b'
	end
	x() = 'c'
end

describe("rule choice point using mixture of short and long form function definitions") do

	gn = RCMixedGen()

  @repeat test("returns 'a' or 'b' or 'c'") do
		td = gen(gn)
		@mcheck_values_are td ['a','b','c']
	end
	
end
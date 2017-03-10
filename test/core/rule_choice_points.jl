# tests rule choice points

@generator RCShortGen begin # prefix RC (for Rule Choice points) to avoid type name clashes
    start() = x()
    x() = 'a'
    x() = 'b'
    x() = 'c'
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

@generator RCMixedGen begin
    start() = x()
    x() = 'a'
    function x()
        'b'
    end
    x() = 'c'
end

@testset "rule choice points" begin

	@testset "rule choice point using short form function definitions" begin
	
	    gn = RCShortGen()
	
		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
        	td = choose(gn)
			@mtest_values_are ['a','b','c'] td
		end

	end

	@testset "rule choice point using long form function definitions" begin

	    gn = RCLongGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
        	td = choose(gn)
			@mtest_values_are ['a','b','c'] td
		end

	end

	@testset "rule choice point using mixture of short and long form function definitions" begin

	    gn = RCMixedGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
        	td = choose(gn)
			@mtest_values_are ['a','b','c'] td
		end
	
	end
	
end
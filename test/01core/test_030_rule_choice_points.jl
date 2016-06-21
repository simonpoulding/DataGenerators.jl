# tests rule choice points

# basic reps choice point

@generator RCShortGen begin # prefix RC (for Rule Choice points) to avoid type name clashes
    start() = x()
    x() = 'a'
    x() = 'b'
    x() = 'c'
end

@testset "rule choice point using short form function definitions" begin
    gn = RCShortGen()
    @testset "returns 'a' or 'b' or 'c'" for i in 1:NumReps 
        td = choose(gn)
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

@testset "rule choice point using long form function definitions" begin

    gn = RCLongGen()

    @testset "returns 'a' or 'b' or 'c'" for i in 1:NumReps 
        td = choose(gn)
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

@testset "rule choice point using mixture of short and long form function definitions" begin

    gn = RCMixedGen()

    @testset "returns 'a' or 'b' or 'c'" for i in 1:NumReps 
        td = choose(gn)
        @mcheck_values_are td ['a','b','c']
    end
	
end
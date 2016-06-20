# tests generate function

using GodelTest

@generator GNStartFuncGen() begin # prefix GN (for GeNerate) to avoid type name clashes
    start() = 'a'
    other() = 'b'
end

@testset "generate using different start rules" begin

gn = GNStartFuncGen()

@testset "default start rule" begin
    td = first(generate(gn))
    @test td == 'a'
end
	
@testset "non-default start rule" begin
    td = first(generate(gn, startrule=:other))
    @test td == 'b'
end
	
end


@generator GNChoiceModelGen() begin # prefix GN (for GeNerate) to avoid type name clashes
    start() = plus(a)
    a() = 'a'
end

# choice model that only returns the lower bound Godel number
type GNMinimumValueChoiceModel <: GodelTest.ChoiceModel; end
import GodelTest.godelnumber
function godelnumber(cm::GNMinimumValueChoiceModel, cc::GodelTest.ChoiceContext)
return cc.lowerbound, Dict()
end

@testset "generate using default and non-default choice models" begin

gn = GNChoiceModelGen()
	
@testset repeats=NumReps "default choice model" begin
    td = gen(gn)
    @mcheck_values_include length(td) [1,2,3]	
end

@testset repeats=NumReps "non-default choice model" begin
    td = gen(gn, choicemodel=GNMinimumValueChoiceModel())
    @mcheck_values_are length(td) [1,]	
end
	
end


@generator GNIntGen begin
    start() = choose(Int,5,9)
end

@generator GNMainGen(intGen) begin
    start() = plus(intGen())
end

@testset "generate a generator with sub-generators using default and non-default choice models" begin

ign = GNIntGen()
gn = GNMainGen(ign)
	
@testset repeats=NumReps "default choice model" begin
    td = gen(gn)
    @mcheck_values_include first(td) [5,6,7]	
end

@testset repeats=NumReps "non-default choice model" begin
    td = gen(gn, choicemodel=GNMinimumValueChoiceModel())
    @mcheck_values_are first(td) [5,]	
end
	
end


@generator GNInfRecursionGen() begin
    start = [plus(start)]
end

@generator GN100ChoicesGen() begin
    start = map(i->a,1:50) # each invocation of a requires two choice points
    a = choose(Int,1,10)
    a = plus(b)
    b = 'b'
end

@testset "limit on number of choice points (maxchoices)" begin

infgn = GNInfRecursionGen()
	
@testset "infinite recursion throws GenerationTerminatedException" begin	
    exc = nothing
    try
        td = gen(infgn)
    catch e
        if isa(e,GenerationTerminatedException)
            exc = e
        else
            throw(e)
        end
    end
    # TODO use @check_throws instead
    @test typeof(exc) == GenerationTerminatedException
    # check for sensible reason that specifies the limit
    @test match(r"choices", exc.reason) != nothing
    @test match(r"exceeded", exc.reason) != nothing
    @test match(Regex("$(GodelTest.MAX_CHOICES_DEFAULT)"), exc.reason) != nothing 
end
	
c100gn = GN100ChoicesGen()
	
@testset "number of choices <= maxchoices parameter to generator" begin	
    exc = nothing
    try
        td = gen(c100gn, maxchoices = 99)
    catch e
        if isa(e,GenerationTerminatedException)
            exc = e
        else
            throw(e)
        end
    end
    # TODO use @check_throws instead
    @test typeof(exc) == GenerationTerminatedException
end

@testset "number of choices > maxchoices parameter to generator" begin	
    exc = nothing
    try
        td = gen(c100gn, maxchoices = 100)
    catch e
        if isa(e,GenerationTerminatedException)
            exc = e
        else
            throw(e)
        end
    end
    # TODO use @check_throws instead
    @test typeof(exc) != GenerationTerminatedException
end

@testset "robustgen with number of choices <= maxchoices parameter to generator" begin	
    @test robustgen(c100gn, maxchoices = 99) == nothing
end

@testset "robustgen with number of choices > maxchoices parameter to generator" begin	
    @test robustgen(c100gn, maxchoices = 100) != nothing
end
	
end



@generator GNMultGen() begin
    start = mult(a)
    a = :a
end

@testset "limit on sequence choice point reps (maxseqreps)" begin

gn = GNMultGen()
	
# note that to force sufficiently long sequences to reach the default limit
# we need to use the sampler choice model rather than a default choice model
# (but sampler choice model itself is only tested later)
scm = SamplerChoiceModel(gn)
# sampler choice model should have a single parameter that controls the geometric distribution
# set this to a value close to zero so that median length is much larger than the default maxseqreps
setparams(scm, [0.000001])

@testset repeats=NumReps "sequence are no longer than the default limit" begin
    exc = nothing
    td = nothing
    try
        td = gen(gn, choicemodel = scm)
    catch e
        if isa(e,GenerationTerminatedException)
            exc = e
        else
            throw(e)
        end
    end
    @test (exc != nothing) || (length(td) <= GodelTest.MAX_SEQ_REPS_DEFAULT) # check that limit applies
    @mcheck_that_sometimes typeof(exc) == GenerationTerminatedException
    if (exc != nothing)
        @test match(r"repetitions", exc.reason) != nothing
        @test match(r"exceeded", exc.reason) != nothing
        @test match(Regex("$(GodelTest.MAX_SEQ_REPS_DEFAULT)"), exc.reason) != nothing
    end
end

@testset repeats=NumReps "sequence are no longer than the specified limit" begin
    exc = nothing
    td = nothing
    try
        td = gen(gn, choicemodel = scm, maxseqreps = 87)
    catch e
        if isa(e,GenerationTerminatedException)
            exc = e
        else
            throw(e)
        end
    end
    @test (exc != nothing) || (length(td) <= GodelTest.MAX_SEQ_REPS_DEFAULT) # check that limit applies
    @mcheck_that_sometimes typeof(exc) == GenerationTerminatedException
    if (exc != nothing)
        @test match(r"repetitions", exc.reason) != nothing
        @test match(r"exceeded", exc.reason) != nothing
        @test match(Regex("87"), exc.reason) != nothing
    end
end

end

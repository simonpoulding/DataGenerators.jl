# tests generate function

@generator GNStartFuncGen() begin # prefix GN (for GeNerate) to avoid type name clashes
    start() = 'a'
    other() = 'b'
end

@generator GNChoiceModelGen() begin # prefix GN (for GeNerate) to avoid type name clashes
    start() = plus(a)
    a() = 'a'
end

@generator GNIntGen begin
    start() = choose(Int,5,9)
end

@generator GNMainGen(intGen) begin
    start() = plus(choose(intGen))
end

@generator GNInfRecursionGen() begin
    start() = [plus(start)]
end

@generator GN100ChoicesGen() begin
    start() = map(i->a(),1:50) # each invocation of a requires two choice points
    a() = choose(Int,1,10)
    a() = plus(b)
    b() = 'b'
end

@generator GNMultGen() begin
    start() = mult(a)
    a() = :a
end


@testset "generate" begin

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

	@testset "default choice model is a sampler choice model" begin
	
		gn = GNChoiceModelGen()	
		@test isa(choicemodel(gn), DataGenerators.SamplerChoiceModel)

	end

	@testset "generate using default and non-default choice models" begin

		gn = GNChoiceModelGen()
		
		@test isa(choicemodel(gn), DataGenerators.SamplerChoiceModel)
	
		@mtestset "default choice model" reps=Main.REPS alpha=Main.ALPHA begin
	    	td = choose(gn)
			@mtest_values_include [1,2,3] length(td)
		end

		setminimumvaluechoicemodel!(gn)

		@mtestset "non-default choice model" reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
			@mtest_values_are [1,] length(td)
		end
	
	end


	@testset "generate a generator with sub-generators using default and non-default choice models" begin

		ign = GNIntGen()
		gn = GNMainGen(ign)
	
		@mtestset "default choice model" reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @mtest_values_include [5,6,7] first(td)
		end

		setminimumvaluechoicemodel!(gn)
		setminimumvaluechoicemodel!(ign)

		@mtestset "non-default choice model" reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @mtest_values_are [5,] first(td)
		end
	
	end


	@testset "limit on number of choice points (maxchoices)" begin

		infgn = GNInfRecursionGen()
	
		@testset "infinite recursion throws GenerationTerminatedException" begin	
		    exc = nothing
		    try
		        td = choose(infgn)
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
		    @test match(Regex("$(DataGenerators.defaultgenerateparams[:maxchoices])"), exc.reason) != nothing 
		end
	
		c100gn = GN100ChoicesGen()
	
		@testset "number of choices <= maxchoices parameter to generator" begin	
		    exc = nothing
		    try
		        td = choose(c100gn, maxchoices = 99)
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
		        td = choose(c100gn, maxchoices = 100)
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
		    @test robustchoose(c100gn, maxchoices = 99) == nothing
		end

		@testset "robustgen with number of choices > maxchoices parameter to generator" begin	
		    @test robustchoose(c100gn, maxchoices = 100) != nothing
		end
	
	end



	@testset "limit on sequence choice point reps (maxseqreps)" begin

		gn = GNMultGen()
	
		# note that to force sufficiently long sequences to reach the default limit
		# we need to use the sampler choice model rather than a default choice model
		# (but sampler choice model itself is only tested later)
		setsamplerchoicemodel!(gn)
		
		# sampler choice model should have a single parameter that controls the geometric distribution
		# set this to a value close to zero so that median length is much larger than the default maxseqreps
		setparams!(choicemodel(gn), [0.000001])
		
		@mtestset "sequence are no longer than the default limit" reps=Main.REPS alpha=Main.ALPHA begin
		    exc = nothing
		    td = nothing
		    try
		        td = choose(gn)
		    catch e
		        if isa(e,GenerationTerminatedException)
		            exc = e
		        else
		            throw(e)
		        end
		    end
		    @test (exc != nothing) || (length(td) <= DataGenerators.defaultgenerateparams[:maxseqreps]) # check that limit applies
		    @mtest_that_sometimes typeof(exc) == GenerationTerminatedException
		    if (exc != nothing)
		        @test match(r"repetitions", exc.reason) != nothing
		        @test match(r"exceeded", exc.reason) != nothing
		        @test match(Regex("$(DataGenerators.defaultgenerateparams[:maxseqreps])"), exc.reason) != nothing
		    end
		end

		@mtestset "sequence are no longer than the specified limit" reps=Main.REPS alpha=Main.ALPHA begin
		    exc = nothing
		    td = nothing
		    try
		        td = choose(gn, maxseqreps = 87)
		    catch e
		        if isa(e,GenerationTerminatedException)
		            exc = e
		        else
		            throw(e)
		        end
		    end
		    @test (exc != nothing) || (length(td) <= DataGenerators.defaultgenerateparams[:maxseqreps]) # check that limit applies
		    @mtest_that_sometimes typeof(exc) == GenerationTerminatedException
		    if (exc != nothing)
		        @test match(r"repetitions", exc.reason) != nothing
		        @test match(r"exceeded", exc.reason) != nothing
		        @test match(Regex("87"), exc.reason) != nothing
		    end
		end
	
	end

end
# tests generate function

using GodelTest

@generator GNStartFuncGen() begin # prefix GN (for GeNerate) to avoid type name clashes
	start() = 'a'
	other() = 'b'
end

describe("generate using different start rules") do

	gn = GNStartFuncGen()

  test("default start rule") do
		td = first(generate(gn))
		@check td == 'a'
	end
	
  test("non-default start rule") do
		td = first(generate(gn, startrule=:other))
		@check td == 'b'
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
	return cc.lowerbound
end

describe("generate using default and non-default choice models") do

	gn = GNChoiceModelGen()
	
	@repeat test("default choice model") do	
		td = gen(gn)
		@mcheck_values_include length(td) [1,2,3]	
	end

	@repeat test("non-default choice model") do	
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

describe("generate a generator with sub-generators using default and non-default choice models") do

	ign = GNIntGen()
	gn = GNMainGen(ign)
	
	@repeat test("default choice model") do	
		td = gen(gn)
		@mcheck_values_include first(td) [5,6,7]	
	end

	@repeat test("non-default choice model") do	
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

describe("limit on number of choice points") do

	infgn = GNInfRecursionGen()
	
	test("infinite recursion throws GenerationTerminatedException") do	
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
		@check typeof(exc) == GenerationTerminatedException
		# check for sensible reason that specifies the limit
		@check match(r"choices", exc.reason) != nothing
		@check match(r"exceeded", exc.reason) != nothing
		@check match(r"10000", exc.reason) != nothing 
	end
	
	c100gn = GN100ChoicesGen()
	
	test("number of choices <= maxchoices parameter to generator") do	
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
		@check typeof(exc) == GenerationTerminatedException
	end

	test("number of choices > maxchoices parameter to generator") do	
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
		@check typeof(exc) != GenerationTerminatedException
	end

	test("robustgen with number of choices <= maxchoices parameter to generator") do	
		@check robustgen(c100gn, maxchoices = 99) == nothing
	end

	test("robustgen with number of choices > maxchoices parameter to generator") do	
		@check robustgen(c100gn, maxchoices = 100) != nothing
	end
	
end

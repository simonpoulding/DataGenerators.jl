# Simplified equivalents of @mcheck macros from AutoTest.jl, implemented using customization features of Base.Test in Julia 0.5
# Adds new @mtest_distributed_as to test distributions
# Simon Poulding, 2017

module MultiTest

export MultiTestSet, @mtest_values_vary, @mtest_values_are, @mtest_values_include, @mtest_that_sometimes, @mtest_distributed_as

import Base.Test: record, finish
using Base.Test: AbstractTestSet, DefaultTestSet, Result, Pass, Fail, Error, ExecutionResult, Returned, Threw, get_testset
using HypothesisTests

# wrap DefaultTestSet with additional fields for samples taken at mtest macros
# we need DefaulTestSet since it handles pretty printing and accummulation of results
type MultiTestSet <: AbstractTestSet
	defaultts::DefaultTestSet
	mtests::Dict{Symbol, Function}
	samples::Dict{Symbol, Vector}
	MultiTestSet(desc) = new(DefaultTestSet(desc), Dict{Symbol, Function}(), Dict{Symbol, Vector}())
end 

# for normal tests, record against the wrapped default test set
record(ts::MultiTestSet, child::AbstractTestSet) = record(ts.defaultts, child)
record(ts::MultiTestSet, res::Result) = record(ts.defaultts, res)

# at end of multitest set, evaluate samples against corresponding mtest closures and record results in the wrapped default test set,
# then finish the wrapped test set so that results accumulate appropriately
function finish(ts::MultiTestSet)
	for (id, mtestclosure) in ts.mtests
		s = get(ts.samples, id, [])
		res = try
				testresult, testname, testexpr, testparams = mtestclosure(s)
				testdesc = string(testname) * " " * testexpr * " " * testparams * "\n      Sample: " * string(s) 	
				# this description (macroname evaluand & any parameters) will be reported by DefaultTestSet after the label "Expression:"
				# the spaces after the \n aligns the label "Sample:" on the second line to this
				testresult ? Pass(testname, testdesc, nothing, nothing) : Fail(testname, testdesc, nothing, nothing)
			catch _e
				Error(:mtest, nothing, _e, catch_backtrace())
			end
		record(ts.defaultts, res)
	end
	finish(ts.defaultts)
end

# register a mtest macro first time it is executed, to record both id and the test function (as a closure including any parameters 
# such as expected results)
register_mtest(ts::MultiTestSet, id::Symbol, mtestclosure::Function) = ts.mtests[id] = mtestclosure

is_mtest_registered(ts::MultiTestSet, id::Symbol) = haskey(ts.mtests, id)

# add result to sample (or report error during test)
function add_to_mtest_sample(ts::MultiTestSet, id::Symbol, result::ExecutionResult, origex)
    if isa(result, Returned)
		s = get!(Vector{Any}, ts.samples, id)
		push!(s, result.value)
    else
        # The predicate couldn't be evaluated without throwing an
        # exception, so that is an Error and not a Fail
        @assert isa(result, Threw)
        testres = Error(:test_error, origex, result.exception, result.backtrace)
	    record(ts, testres)
    end
end

# simplified form of Base.Test.get_test_result: special handling for comparisons is removed as we don't need it (but see mtest_that_sometimes)
function get_mtest_result_expr(ex) 
    testret = :(Returned($(esc(ex)), nothing))
    resultex = quote
        try
            $testret
        catch _e
            Threw(_e, catch_backtrace())
        end
    end
    Base.remove_linenums!(resultex)
    resultex
end

# common code for all mtest macros: output is code to register mtest instance and its associated closure (if first time executed),
# and then add value to the sample
function mtest_macro(ex, paramex, mtestclosureex)
    origex = Expr(:inert, ex)
    resultex = get_mtest_result_expr(ex)
	id = gensym(:mtest)
	idstr = string(id)
	tsvar = gensym(:ts)
    quote 
		$tsvar = get_testset()
		if !is_mtest_registered($tsvar, Symbol($idstr))
			$paramex
			register_mtest($tsvar, Symbol($idstr), $mtestclosureex)
		end
		add_to_mtest_sample($tsvar, Symbol($idstr), $resultex, $origex)
	end
end

# mtest_values_vary
macro mtest_values_vary(ex)
	paramex = :( nothing ) 
	mtestclosureex = :( _s->(length(unique(_s))>1, :mtest_values_vary, $(string(ex)), "") )
	mtest_macro(ex, paramex, mtestclosureex)
end

# mtest_values_are
macro mtest_values_are(ex, expex)
	expvar = gensym(:exp)
	paramex = :( $expvar = $(esc(expex)) )
	mtestclosureex = :( _s->(sort(unique(_s))==sort(unique($expvar)), :mtest_values_are, $(string(ex)), string($expvar)) )
	mtest_macro(ex, paramex, mtestclosureex)
end

# mtest_values_include
macro mtest_values_include(ex, expex)
	expvar = gensym(:exp)
	paramex = :( $expvar = $(esc(expex)) )
	mtestclosureex = :( _s->(issubset($expvar, _s), :mtest_values_include, $(string(ex)), string($expvar)) )
	mtest_macro(ex, paramex, mtestclosureex)
end

# mtest_that_sometimes
macro mtest_that_sometimes(ex)
	paramex = :( nothing ) 
	mtestclosureex = :( _s->(any(_s), :mtest_that_sometimes, $(string(ex)), "") )
	mtest_macro(ex, paramex, mtestclosureex)
	# in description of sample, could handle comparison in same way that DefaultTestSet does to report both sides rather than result
end

# mtest_distributed_as
# comparison need not be a Distribution - needs only to permit rand( ,n); a vector would work
# test is that ranksum test against a sample of the same length from the distribution has a p-value above significance level alpha
macro mtest_distributed_as(ex, distex, alphaex)
	distvar = gensym(:dist)
	alphavar = gensym(:alpha)
	paramex = :( $distvar = $(esc(distex)); $alphavar = $(esc(alphaex)) )
	mtestclosureex = :( _s->(pvalue(MannWhitneyUTest(convert(Vector{Real},_s), rand($distvar, length(_s)))) > $alphavar,
		 					:mtest_distributed_as, $(string(ex)), string($distvar) * " " * string($alphavar)) )
	mtest_macro(ex, paramex, mtestclosureex)
end

end


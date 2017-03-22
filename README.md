# DataGenerators

DataGenerators is a data generation package for [Julia](http://julialang.org/). It can use search and optimisation techniques to find data that, for example, can improve software testing by generating more effective test data.

You can write your own data generators utilizing the full power of Julia, or use the [DataGeneratorTranslators](https://github.com/simonpoulding/DataGeneratorTranslators.jl) package to automatically create data generators from specifications such as Backus-Naur Form (BNF), XML Schema Definition (XSD), and regular expressions.


## Installation

Install by cloning the package directly from GitHub -- including two packages it requires, `DataGeneratorTranslators` and `BaseTestMulti` -- from a Julia REPL:

    julia> Pkg.clone("https://github.com/simonpoulding/BaseTestMulti.jl")
    julia> Pkg.clone("https://github.com/simonpoulding/DataGeneratorTranslators.jl")
    julia> Pkg.clone("https://github.com/simonpoulding/DataGenerators.jl")


## Usage

Don't forget to load the package:

	julia> using DataGenerators


### Generators

#### A First Example

A *generator* consists of rules which are written as Julia functions, and are defined using the `@generator` macro:

	julia> @generator NumXStrGen begin
		start() = join(plus(item()))
		item() = 'X'
		item() = choose(Int,0,9)
	end


Data generation begins by executing the `start` rule-function, which in turn calls other rule-functions and accepts the values they return.  The value returned by the `start` rule-function is the value emitted when the generator is run.

Here the `start` rule-function uses `plus`, a special DataGenerator construct that creates a list of length of 1 or more by repeatedly executing its argument.  The length of the list is decided each time `plus` is executed.

The argument of `plus` is a call to the `item` rule-function.  There are two `item` rule-functions defined in the generator, and which one of the two is executed is decided each time the rule-function is called.

The second `item` rule-function uses another DataGenerator construct, `choose`, to select a value from a data type: here an integer between 0 and 9.  Again, which value is returned is decided each time `choose` is executed.

The macro creates the generator as Julia type, in this case named `NumXStrGen`.  To run the generator so that it emits a datum, first create an instance of the generator, and then call choose on that instance:

    julia> g = NumXStrGen()
	data generator NumXStrGen with 3 choice points using sampler choice model
	
	julia> choose(g)
	"8X37X"
	 
	julia> choose(g)
	"X0"
	 
(For convenience, it is also possible to apply `choose` directly to the generator type itself: `choose(NumXStrGen)`.)

The `NumXStrGen` generator emits a string consisting of digits and the letter X.  The length of the list returned by `plus`, which `item` rule-function is executed, and the digit returned by `choose` are called *choice points*.  The default behaviour is that the random choices are made at these choice points.  (A powerful feature of `DataGenerators` is that this behaviour can be changed and refined: see the section 'Choice Models' below.)  Therefore each time the generator is run using `choose`, a string of different length and consisting of different combinations of Xs and digits is returned.

#### Choice Points

##### Rule Choice Points

*Rule choice points* occur when two or more rule-functions in the generator have the same name.

The default behaviour is to choose one of the rule-functions at random, with all having the same probability of being chosen.

##### Sequence Choice Points

*Sequence choice points* are defined using one of the following constructs:

* `mult(x)` - returns a list (Vector) of zero or more items
* `plus(x)` - returns a list of one or more items
* `reps(x, a, b)` - returns a list with length between `a` and `b` inclusive (if `b` is omitted, then there is no upper bound)

`x` is often a call to another rule-function, in which case either the just rule-function name (e.g. `item`) *or* the full call syntax (`item()`) may be used.  `x` many also be any expression that returns a value, including a constant.

The default behaviour is to choose the length of list according to a Geometric distribution so that short lists are more
likely than longer lists.

##### Value Choice Points

*Value choice points* are defined using one of the following constructs:

* `choose(Bool)` - returns `true` or `false` (i.e. a value of type Bool).  The default behaviour is to choose these values using a Bernoulli distribution such that true and false have the same probability of being chosen.
* `choose(T, a, b)` where `T` is one of the following numeric types: `Int`, `Int8`, `Int16`, `Int32`, `Int64`, `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`, `Float16`, `Float32`, or `Float64` -  returns a value of that is between `a` and `b`.  If both `a` and `b` are omitted, no bounds are placed on the value chosen.  If `b` is omitted, no upper is placed on the value chosen.  The default behaviour is to choose from values according a uniform distribution so that all values in the range have the same probability of being chosen. 
* `choose(String, r)` - returns a string that conforms to the regular expression `r` (`r` should be specified using a Julia String rather than a Regex type).  If `r` is not specified, a variable length string of any characters is returned.  (This construct uses the `DataGeneratorTranslators` package to construct additional generator rule-functions to return values that satisfy the regular expression.)

The Julia built-in function `rand` could be used instead of `choose` when random values are required, but `choose` is preferred since enables finer control over how the values are chosen (see the section 'Choice Models' below).  A call to `rand` is not identified as a choice point by the `@generator` macro.

#### Functions, not Production Rules

Although generator rule-functions resemble the production rules of a formal grammar, they differ in that they are functions written in a Turing complete language, here Julia.  This is one of the distinguising features of `DataGenerators`.  It enables rule-functions to be much expressive and compact than formal production rules since, like any other Julia functions, rule-functions can use all the features of the Julia standard library and installed packages.  For example, the `NumXStrGen` generator above uses the function `join` from the standard library to concenate the items in a list to form a string.

The rule-functions need not be limited to short-form function syntax such as `item() = choose(Int,0,9)`. Longer-form syntax may also be used in generators, including functions with local variables:


	julia> @generator FibStrGen begin
		start() = begin
			join(plus(fib), " ")
		end
		function fib()
			fn0 = 0
			fn1 = 1
			for i in 1:choose(Int,0,10)
				fn2 = fn0 + fn1
				fn0 = fn1
				fn1 = fn2
			end
			fn0
		end
	end
	
	julia> choose(FibStrGen)
	"55 1 34"
	
	julia> choose(FibStrGen)
	"0 21 2 55"


#### Passing Arguments to Rules

Another difference from the production rules of a formal grammar is that arguments may be passed between rule-functions.  A consequence of this is that generator as a whole, or a subset of rule-functions, can pass state between them.  This mechanism enables constraints between elements within the datum emitted by the generator to be satisfied in a straightforward manner.  For example:

	julia> @generator DateGen begin
		start() = begin
			y = year()
			m = month()
			d = day(y, m)
			Date(y, m, d)
		end
		year() = choose(Int, 1583, 2999)
		month() = choose(Int, 1, 12)
		day(y, m) = choose(Int, 1, Dates.daysinmonth(Date(y, m)))
	end

(`Dates.daysinmonth` is a built-in Julia function)

#### Subgenerators

Generators may call other generators.  The generators that are called -- the *subgenerators* -- are declared as parameters in the generator definition, and then instances of the subgenerators are passed as arguments when an instance of the generator is created. For example:
	
	julia> @generator DictGen(keyGen, valueGen) begin
	    start() = Dict(plus(pair))
		pair() = choose(keyGen)=>choose(valueGen)
	end

	julia> @generator ShortStringGen begin
		start() = choose(String, "[A-Z]{5,15}")
	end
	
	julia> @generator SmallIntGen begin
		start() = choose(Int16)
	end
		
	julia> sg = ShortStringGen()
	data generator ShortStringGen with 2 choice points using sampler choice model

	julia> ig = SmallIntGen()
	data generator SmallIntGen with 1 choice points using sampler choice model

	julia> g = DictGen(sg, ig)
	data generator DictGen with 1 choice points using sampler choice model
	
	julia> choose(g)
	Dict{String,Int16} with 3 entries:
	  "DPFMV"  => 16152
	  "MUFIOY" => -17445
	  "RSNWTD" => 5122


#### Generation Parameters

Additional named parameters can be passed to `choose(g)` (where g is a generator instances) to control the generation process:

* `startrule=<rulename>` (default: `:start`) - generation begins from specified rule name (which should be specified as a Symbol)
* `maxchoices=<integer>` (default: 10017) - specifies the maximum number of choices to be made, above which an exception is raised
* `maxruledepth=<integer>` (default: 11765) - specifies the maximum rule call depth, above which an exception is raised
* `maxseqreps=<integer>` (default: 4848) - specifies the an upper limit on the length of lists (sequences), above which an exception is raised
	
The purpose of the last three parameters is to limit data structures that are unbounded in size (e.g. tree-like structures).  A `GenerationTerminatedException` is raised when one of the limits is exceeded.  Alternatively, `robustchoose` can be used in place of `choose` in which case the exception is silently caught and `nothing` returned as the datum from the generator.
	
#### Automatic Creation of Generators

As alternative to writing generators manually, the DataGeneratorTranslators package automatically create generators from supported specifications such as Backus-Naur Form (BNF), XML Schema Definition (XSD), and regular expressions.  The resulting generator code can be used immediately by the `DataGenerators` package, refined manually (e.g. to incorporate constraints missing from the specification), or as the starting point for manually-created generator.  See the README in the [DataGeneratorTranslators](https://github.com/simonpoulding/DataGeneratorTranslators.jl) package for more details.

	
### Choice Models

A *choice model* determines how choices at choices points are made.  There is a clear separation of choice model from the generator in `DataGenerators`, and this abstraction permits algorithms to be applied to the choice model regardless of the specifics of the generator.  For example, the choice model can be manipulated by metaheuristic algorithms to optimise the characteristics of the data returned by generator; one such characteristic may be the effectiveness of the data in finding faults when used as test inputs.

Choice models may be deterministic or stochastic. By default, a generator is assigned a *sampler choice model* which is stochastic: each choice point has a probability distribution assigned to it and random numbers sampled from the distribution are used to make the choices.  The default behaviour described in the section 'Choice Points' above is a result of the sampler choice model.

Each type choice model provided by `DataGenerators` supplies a function that sets the choice model of a generator instance:

	julia> @generator SmallIntGen begin
		start() = choose(Int16)
	end
	
	julia> g = SmallIntGen()
	data generator SmallIntGen with 1 choice points using sampler choice model
	
	julia> setsimplechoicemodel!(g)
	data generator SmallIntGen with 1 choice points using simple choice model
	
	julia> setsamplerchoicemodel!(g)
	data generator SmallIntGen with 1 choice points using sampler choice model
	
	julia> setnmcschoicemodel!(g, x->length(x))
	data generator SmallIntGen with 1 choice points using NMCS choice model (policy: sampler choice model)

The *simple choice model* is a naive stochastic choice model that is used mainly for testing the `DataGenerators` package.  The *NMCS choice model* is described below in the section 'Optimising the Generation Process'.

Further choice models, such as deterministic choice models, will be provided in future versions of the `DataGenerators` package.  Currently, the default *sampler choice model* is recommended for generating random data.


#### Optimising the Choice Model

Choice models typically have parameters.  The parameters of a sampler choice model are the set of distribution parameters that control the shape of the probability distributions assigned to each choice point.  For example, a Geometric distribution that determines the length of lists created by a sequence choice point has one parameter between 0 and 1.  Values of this parameter closer to 0 result in longer sequence on average; values closer to 1 results in shorter lists on average.  Manipulating the parameters of the choice model changes the characteristics of the data emitted by the generator.  To put it another way: the sampler choice model defines a probability distribution over all data that could be emitted by the generator, and changing the parameters changes that distribution.

If we wish to optimise the probability distribution defined by the choice model -- for example, to favour test data with particular useful characteristics -- this can be done by manipulating the parameters of the choice model.  The following functions are provided for this purpose:

* `choicemodel(g)` where `g` is a generator instance - returns the current choice model for that generator
* `getparams(cm)` where `cm` is a choicemodel - returns the choice model parameters as a `Vector{Float64}`
* `setparams!(cm, v)` where `cm` is a choicemodel, and `v` is a `Vector{Float64}` - sets the choice model parameters to those in Vector (in the same order as `getparams`)
* `paramranges(cm)` where `cm` is a choicemodel - returns the bounds on the choice model parameters as a `Vector{Tuple{Float64,Float64}}` (in the same order as `getparams`) where the first entry in the Tuple is the lower bound, and the second the upper bound

To facilitate optimisation by metaheuristic algorithms, the sampler choice model accepts *any* vector of parameters that satisfy the ranges specified by `paramranges`. Any constraints between subsets of parameter values in the Vector that are not met are handled sensibly by `setparams!' instead of raising an exception, and so such constraints need not be considered by the algorithm.

The following example uses Different Evolution algorithm to optimise the parameters of the model to return arithmetic expressions with a length of approximately 100.  (To install the `BlackBoxOptim` package used in this example, use `Pkg.add("BlackBoxOptim")`.)

	using DataGenerators
	using BlackBoxOptim
	
	# generator for arithmetic expressions
	@generator ExprGen begin
	  start() = expression()
	  expression() = operand() *  operator() * operand()
	  operand() = "(" * expression() * ")"
	  operand() = (choose(Bool) ? "-" : "") * join(plus(digit))
	  digit() = choose(Int,0,9)
	  operator() = "+"
	  operator() = "-"
	  operator() = "/"
	  operator() = "*"
	end
	
	# function to return length of the expression, or a penalty value of 1000 if a limit was reached in the generator
	exprlength(g) = begin
		expr = robustchoose(g)
		expr == nothing ? 1000 : length(expr)
	end
	
	# mean length of 200 expressions sampled for the generator
	meanexprlength(g) = mean([exprlength(g) for i in 1:200])
		
	# function to return a closure that acts as a fitness function (lower is better) for the generator
	fitnessfn(g) = params -> begin
		setparams!(choicemodel(g), params)
		abs(100 - meanexprlength(g))
	end
	
	# create a generator instance
	eg = ExprGen()
	
	# optimise for a maximum of 60 seconds
	optimresult = bboptimize(fitnessfn(eg); SearchRange=paramranges(choicemodel(eg)), MaxTime=60.0)
	
	# set the parameter of the choice model to the best candidate found
	setparams!(choicemodel(eg), best_candidate(optimresult))
	
	# generate using the optimised choice model
	choose(eg)


See our paper "[Finding Test Data with Specific Properties via Metaheuristic Search](http://www.robertfeldt.net/publications/feldt_2013_godeltest.html)" [1] for an example of this technique applied to generating trees of a specified size and depth.

#### Optimising the Generation Process

An alternative to optimising the choice model parameters is to optimise each choice made by the generator as it is made.  One such approach is to 'look ahead' to estimate the effect of each choice using Nested Monte-Carlo Search (NMCS), a form of Monte-Carlo Tree Search.  We implement this as the NMCS choice model as the following example, using the same expression generator as above, demonstrates:

	using DataGenerators
	
	@generator ExprGen begin
	  start() = expression()
	  expression() = operand() *  operator() * operand()
	  operand() = "(" * expression() * ")"
	  operand() = (choose(Bool) ? "-" : "") * join(plus(digit))
	  digit() = choose(Int,0,9)
	  operator() = "+"
	  operator() = "-"
	  operator() = "/"
	  operator() = "*"
	end
		
	# define fitness function for a single datum (penalty value of 1000 if a limit was reached in the generator)
	# target is expression of length 100
	fitness(expr) = expr == nothing ? 1000 : abs(100 - length(expr))
		
	# create a generator instance
	eg = ExprGen()
	
	# set NMCS choice model: the second parameter is a fitness function applied to the generated datum,
	# and the third number of choices to evaluate at each choice point: higher numbers improve accuracy 
	# at the cost of time taken to generate
	# note that the original choice model is retained as the policy used by NMCS
	setnmcschoicemodel!(eg, fitness, 2)
	
	# generate using the NMCS choice model
	choose(eg)


See our papers "[Generating Structured Test Data with Specific Properties using Nested Monte-Carlo Search](http://www.robertfeldt.net/publications/poulding_2014_godeltest_with_nmcs.html)" [2] and "[The Automated Generation of Human-Comprehensible XML Test Sets](http://www.simonpoulding.net/papers/nasbase_2015_preprint.pdf) [3] for examples of this technique applied to generating trees and XML respectively.


#### Re-estimating the Choice Model

A second approach for optimising choice model parameters is to re-estimate these parameters from choices made when generating data that has the desired characteristics.  This approach uses *generation traces* -- records of the choices made -- that can be obtained by using `generate` instead of `choose` to execute the generator.  In the following example, this technique is applied to the same expression generator as in the two examples above:

	using DataGenerators
	
	# generator for arithmetic expressions
	@generator ExprGen begin
	  start() = expression()
	  expression() = operand() *  operator() * operand()
	  operand() = "(" * expression() * ")"
	  operand() = (choose(Bool) ? "-" : "") * join(plus(digit))
	  digit() = choose(Int,0,9)
	  operator() = "+"
	  operator() = "-"
	  operator() = "/"
	  operator() = "*"
	end
	
	# create a generator instance
	eg = ExprGen()
	
	# execute the generator 200 times, keeping traces where the expression length is within 20% of the target length
	besttraces = Vector{Any}()
	for i in 1:200
		try
			expr, state = generate(eg)
			if 80 <= length(expr) <= 120
				push!(besttraces, state.cmtrace)
			end
		catch _e
			if !isa(_e, GenerationTerminatedException)
				throw(_e)
			end
		end
	end
	
	# re-estimate choice model parameters from the best traces
	estimateparams!(choicemodel(eg), besttraces)
	
	# generate using the optimised choice model
	choose(eg)


See our paper "[Automated Random Testing in Multiple Dispatch Languages](http://www.simonpoulding.net/papers/icst_2017_preprint.pdf)" [7] for an example of this technique applied to the automated generation of typed data for testing Julia functions.



## References

DataGenerators is based in a number of research articles describing our approach (called GodelTest):

[1] R. Feldt and S. Poulding, "[Finding Test Data with Specific Properties via Metaheuristic Search](http://www.robertfeldt.net/publications/feldt_2013_godeltest.html)", ISSRE 2013 (best paper award!)

[2] S. Poulding and R. Feldt, "[Generating Structured Test Data with Specific Properties using Nested Monte-Carlo Search](http://www.robertfeldt.net/publications/poulding_2014_godeltest_with_nmcs.html)", GECCO 2014

[3] S. Poulding and R. Feldt, "[The Automated Generation of Human-Comprehensible XML Test Sets](http://www.simonpoulding.net/papers/nasbase_2015_preprint.pdf), NasBASE, 2015

[4] S. Poulding and R. Feldt, "[Re-using Generators of Complex Test Data](http://www.robertfeldt.net/publications/poulding_2015_reusing_generators_complex_test_data.html)", ICST 2015 

[5] R. Feldt and S. Poulding, "[Broadening the Search in Search-Based Software Testing: It Need Not Be Evolutionary](http://www.robertfeldt.net/publications/feldt_2015_broadening_the_sbst_search.html)", SBST 2015

[6] R. Feldt, S. Poulding, D. Clark and S. Yoo, "[Test Set Diameter: Quantifying the Diversity of Sets of Test Cases](http://www.robertfeldt.net/publications/feldt_2015_test_set_diameter.html)", ICST 2016

[7] S. Poulding and R. Feldt, "[Automated Random Testing in Multiple Dispatch Languages](http://www.simonpoulding.net/papers/icst_2017_preprint.pdf)", ICST 2017


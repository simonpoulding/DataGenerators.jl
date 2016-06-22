DataGenerators.jl
============

DataGenerators is a data generation package for [Julia](http://julialang.org/). It can use techniques for search and optimization to find data that for example can improve testing. You can write your own data generators utilizing the full power of Julia.

Even though DataGenerators can be used as a stand-alone package it supports automated testing with the [BaseTestAuto.jl package](http://www.github.com/robertfeldt/BaseTestAuto.jl).

DataGenerators is based in a number of research articles describing our approach (originally called GodelTest):

* R. Feldt and S. Poulding, "[Finding Test Data with Specific Properties via Metaheuristic Search](http://www.robertfeldt.net/publications/feldt_2013_godeltest.html)", ISSRE 2013 (Best paper award!).

* S. Poulding and R. Feldt, "[Generating Structured Test Data with Specific Properties using Nested Monte-Carlo Search](http://www.robertfeldt.net/publications/poulding_2014_godeltest_with_nmcs.html)", GECCO 2014.

* S. Poulding and R. Feldt, "[Re-using Generators of Complex Test Data](http://www.robertfeldt.net/publications/poulding_2015_reusing_generators_complex_test_data.html)", ICST 2015.

* R. Feldt and S. Poulding, "[Broadening the Search in Search-Based Software Testing: It Need Not Be Evolutionary](http://www.robertfeldt.net/publications/feldt_2015_broadening_the_sbst_search.html)", 2015 IEEE Eigth Int. Workshop on Search-based Software Testing (SBST), 2015.

* R. Feldt, S. Poulding, D. Clark and S. Yoo, "[Test Set Diameter: Quantifying the Diversity of Sets of Test Cases](http://www.robertfeldt.net/publications/feldt_2015_test_set_diameter.html)", ICST 2016.

### Installation

Just install by cloning directly from bitbucket:

    Pkg.clone("https://github.com/simonpoulding/DataGenerators.jl")

from a Julia repl.

### Usage

TBD

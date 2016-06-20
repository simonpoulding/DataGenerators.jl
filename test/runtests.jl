# For now we use the single file, temp version of BaseTestAuto
include("base_test_auto_singlefile_1605.jl")
using BaseTestAuto
include("mcheck_macros_temp.jl") # Temp and incomplete implementations of the mcheck macros

Package = "GodelTest"

using GodelTest

TestFileRE = r"^test_.*\.jl$"

function run(packagename, srcdir = "src", testdir = "test"; 
  testfileregexp = r"^test_.*\.jl$", 
  srcfileregexp = r"^.*\.jl$")

  testfiles = AutoTest.findfiles(testdir, testfileregexp; recursive = true) # in AutoTest this is false
  srcfiles = AutoTest.findfiles(srcdir, srcfileregexp; recursive = true)

  ts = AutoTest.TestSuite(testfiles, srcfiles, "$packagename test suite")

  AutoTest.runtestsuite(ts)

end

#if length(ARGS) > 0 && ARGS[1] == "continuous"
#  AutoTest.autorun(Package, "src", "test")
#else
#  run(Package, "src", "test")
#end

if length(ARGS) >= 1
    NumReps = parse(Int, ARGS[1])
else
    NumReps = 30
end

function include_all_files_matching(re, testdir)
    files = filter(fp -> ismatch(re, fp), readdir("test/$testdir"))
    [include(joinpath(testdir, fp)) for fp in files]
end

@testset "GodelTest test suite" begin
    include_all_files_matching(r"^test_.*jl$", "01core")

    #include_all_files_matching(r"^test_.*jl$", "02internals")
    include(joinpath("02internals", "test_010_choice_point_info.jl"))
    include(joinpath("02internals", "test_080_using_generators_in_different_scopes.jl"))
    include(joinpath("02internals", "test_110_bernoulli_sampler.jl"))

    #include_all_files_matching(r"^test_.*jl$", "03examples")
end
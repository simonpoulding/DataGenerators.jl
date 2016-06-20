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

@testset "GodelTest test suite" begin
    include(joinpath("01core", "test_010_generator_methods.jl"))
    include(joinpath("01core", "test_020_sequence_choice_points.jl"))
    include(joinpath("01core", "test_030_rule_choice_points.jl"))
    include(joinpath("01core", "test_040_value_choice_points.jl"))
    include(joinpath("01core", "test_050_string_value_choice_points.jl"))
end
using AutoTest

Package = "GodelTest"

using GodelTest

function run(packagename, srcdir = "src", testdir = "test"; 
  testfileregexp = r"^test_.*\.jl$", 
  srcfileregexp = r"^.*\.jl$")

  testfiles = AutoTest.findfiles(testdir, testfileregexp; recursive = true) # in AutoTest this is false
  srcfiles = AutoTest.findfiles(srcdir, srcfileregexp; recursive = true)

  ts = AutoTest.TestSuite(testfiles, srcfiles, "$packagename test suite")

  AutoTest.runtestsuite(ts)

end

if length(ARGS) > 0 && ARGS[1] == "continuous"
  AutoTest.autorun(Package, "src", "test")
else
  run(Package, "src", "test")
end
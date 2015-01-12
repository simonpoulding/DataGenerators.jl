using Autotest

Package = "GodelTest"

using GodelTest

function run(packagename, srcdir = "src", testdir = "test"; 
  testfileregexp = r"^test_.*\.jl$", 
  srcfileregexp = r"^.*\.jl$")

  testfiles = Autotest.findfiles(testdir, testfileregexp; recursive = true) # in Autotest this is false
  srcfiles = Autotest.findfiles(srcdir, srcfileregexp; recursive = true)

  ts = Autotest.TestSuite(testfiles, srcfiles, "$packagename test suite")

  Autotest.runtestsuite(ts)

end

if length(ARGS) > 0 && ARGS[1] == "continuous"
  Autotest.autorun(Package, "src", "test")
else
  run(Package, "src", "test")
end
using Autotest

Package = "GodelTest"

using GodelTest

if length(ARGS) > 0 && ARGS[1] == "continuous"
  Autotest.autorun(Package, "src", "test")
else
  Autotest.run(Package, "src", "test")
end
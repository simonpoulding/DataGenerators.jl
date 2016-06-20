Lib = "GodelTest"
TestDir = "test"

# General parameters that the user can set from the command line.
Julia = ENV["minreps"] || "julia"
MinReps = (ENV["minreps"] || 30).to_i
MaxReps = (ENV["maxreps"] || 1000).to_i
MaxRepTime = (ENV["maxreptime"] || 1.0).to_f
Verbosity = ENV["verbosity"] || 2
MoreFactor = (ENV["morefactor"] || 10).to_i
MostFactor = (ENV["mostfactor"] || 1000).to_i
TimedTestMinFactor = (ENV["timedminfactor"] || 10).to_i
TimedTestMaxFactor = (ENV["timedmaxfactor"] || 1000).to_i

MainFile = "src/#{Lib}.jl"
BaseCommand = "nice -9 #{Julia} -L #{MainFile}"

def run_autotest(minReps = MinReps, maxReps = MaxReps, maxRepTime = MaxRepTime, 
  func = "test", timeToRun = -1.0, slowprogressMode = false)
  cmd = "#{BaseCommand} -e 'using AutoTest; AutoTest.#{func}(\"#{Lib}\"; testdir = \"#{TestDir}\", " + 
    "verbosity = #{Verbosity}" +
    ", MinRepetitions = #{minReps}, MaxRepetitions = #{maxReps}, MaxRepeatTime = #{maxRepTime}" +
    ", timeToRun = #{timeToRun}" +
    ", slowprogressMode = #{slowprogressMode}" +
    ")'"
  puts "Running AutoTest tests"
  sh cmd
end

def timed_test(numSeconds)
  run_autotest(MinReps*TimedTestMinFactor, MaxReps*TimedTestMaxFactor, 
    MaxRepTime * 2.0 * Math.log10(TimedTestMaxFactor), 
    "test", numSeconds, true)
end

desc "Run test suite"
task :atest do
  sh "#{BaseCommand} --color=yes test/runtests.jl"
end

desc "Continuous AutoTest testing"
task :autotest do
  #sh "#{Julia} --color=yes test/runtests.jl continuous &"
  sh "#{BaseCommand} --color=yes test/runtests.jl continuous &"
end

desc "Run test suite"
task :test do
  sh "#{BaseCommand} --color=yes test/runtests.jl"
end

desc "Test more; Run more repetitions of AutoTest tests"
task :testmore do
  run_autotest(MinReps*MoreFactor, MaxReps*MoreFactor, 1.0 * 2.0 * Math.log10(MoreFactor))
end

desc "Test most; Run most repetitions of AutoTest tests"
task :testmost do
  run_autotest(MinReps*MostFactor, MaxReps*MostFactor, 1.0 * 2.0 * Math.log10(MostFactor),
    "test", -1.0, true)
end

desc "1 min of testing; Run AutoTest tests for ~1 minute"
task :test1 do
  timed_test(1 * 60)
end

desc "5 min of testing; Run AutoTest tests for ~5 minutes"
task :test5 do
  timed_test(5 * 60)
end

desc "X min of testing; Run AutoTest tests for ~X minutes (example: rake testX[20])"
task :testX, [:X] do |t, args|
  args.with_defaults(:X => "1.0")
  timed_test(args[:X].to_f * 60.0)
end

def filter_latest_changed_files(filenames, numLatestChangedToInclude = 1)
  filenames.sort_by{ |f| File.mtime(f) }[-numLatestChangedToInclude, numLatestChangedToInclude]
end

desc "Run only the latest changed test file"
task :testlatest do
  latest_changed_test_file = filter_latest_changed_files(Dir["test/**/test*.jl"]).first
  sh "#{BaseCommand} --color=yes -e 'using AutoTest; AutoTest.run_tests_in_file(\"#{Lib}\", \"#{latest_changed_test_file}\"; MinRepetitions = #{MinReps}, MaxRepetitions = #{MaxReps})'"
end

desc "Shorthand for testlatest: Run only the latest changed test file"
task :t => :testlatest

def loc_of_files(files)
  lines = files.map {|fn| File.readlines(fn)}
  nonblanklines = lines.map {|ls| ls.select {|line| line.strip.length > 0}}
  loc = lines.map {|ls| ls.length}.inject(0) {|s,e| s+e}
  nbloc = nonblanklines.map {|ls| ls.length}.inject(0) {|s,e| s+e}
  return loc, nbloc, files.length
end

desc "Count LOC"
task :loc do
  srcloc, srcnbloc, numsrcfiles = loc_of_files(Dir["src/**/*.jl"])
  testloc, testnbloc, numtestfiles = loc_of_files(Dir["test/**/*.jl"])
  puts "Source files: #{numsrcfiles} files\t\t#{srcloc} LOC\t\t(#{srcnbloc} non-blank LOC)"
  puts "Test   files: #{numtestfiles} files\t\t#{testloc} LOC\t\t(#{testnbloc} non-blank LOC)"
  if testloc > 0 && srcloc > 0
    puts("Test to code ratio:\t\t%.3f   \t\t(%.3f)" % [(testloc.to_f/srcloc), (testnbloc.to_f/srcnbloc)])
  end
end

# Short hands
task :t => :testlatest

# Default is to run the latest changed test file only:
task :default => :atest
Lib = "GodelTest"
Julia = "julia"
#Julia = "julia04"
TestDir = "test"

MainFile = "src/#{Lib}.jl"
BaseCommand = "#{Julia} --color=yes -L #{MainFile}"

desc "AutoTest testing"
task :atest do
  sh "#{BaseCommand} --color=yes test/runtests.jl"
end

desc "Continuous AutoTest testing"
task :autotest do
  #sh "#{Julia} --color=yes test/runtests.jl continuous &"
  sh "#{BaseCommand} --color=yes test/runtests.jl continuous &"
end

def filter_latest_changed_files(filenames, numLatestChangedToInclude = 1)
  filenames.sort_by{ |f| File.mtime(f) }[-numLatestChangedToInclude, numLatestChangedToInclude]
end

desc "Run only the latest changed test file"
task :testlatest do
  latest_changed_test_file = filter_latest_changed_files(Dir["test/**/test*.jl"]).first
  sh "#{BaseCommand} --color=yes -e 'using AutoTest; AutoTest.run_tests_in_file(\"#{Lib}\", \"#{latest_changed_test_file}\")'"
end

desc "Shorthand for testlatest: Run only the latest changed test file"
task :t => :testlatest

def loc_of_files(files)
  loc = files.map {|fn| File.readlines(fn).length}.inject(0) {|s,e| s+e}
  return loc, files.length
end

desc "Count LOC"
task :loc do
  srcloc, numsrcfiles = loc_of_files(Dir["src/**/*.jl"])
  testloc, numtestfiles = loc_of_files(Dir["test/**/*.jl"])
  puts "Source files: #{numsrcfiles} files\t\t#{srcloc} LOC"
  puts "Test   files: #{numtestfiles} files\t\t#{testloc} LOC"
  puts("Test to code ratio: %.3f" % (testloc.to_f/srcloc))
end

# Short hands
task :t => :testlatest

# Default is to run the latest changed test file only:
task :default => :atest
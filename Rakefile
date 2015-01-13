Julia = "julia"
#Julia = "julia04"

Lib = "GodelTest"

MainCommand = "#{Julia} -L src/#{Lib}.jl -L test/helper.jl"
BaseCommand = "#{Julia} -L src/#{Lib}.jl"

desc "Autotest testing"
task :atest do
  sh "#{BaseCommand} --color=yes test/runtests.jl"
end

desc "Continuous autotest testing"
task :autotest do
  #sh "#{Julia} --color=yes test/runtests.jl continuous &"
  sh "#{BaseCommand} --color=yes test/runtests.jl continuous &"
end

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
task :t => :at

# Default is to run the latest changed test file only:
task :default => :atest
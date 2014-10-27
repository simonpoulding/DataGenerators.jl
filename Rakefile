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

# Short hands
task :t => :at

# Default is to run the latest changed test file only:
task :default => :atest
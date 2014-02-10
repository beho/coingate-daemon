desc 'Run console with loaded classes'
task :console do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end

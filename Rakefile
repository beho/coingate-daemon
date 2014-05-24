ENV['COINGATE_PROCNAME'] = ARGV.last

require_relative 'config/boot'

Dir['lib/tasks/*.rake'].each {|r| import r }

Bundler.require
# puts root
ROOT = Dir.pwd

ENV['RACK_ENV'] ||= 'development'

require_relative 'config/app'
require_relative 'lib/coingate'

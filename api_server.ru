require_relative 'config/boot'

file = File.new("log/api_server.#{ENV['RACK_ENV']}.log", 'a+')
file.sync = true
use Rack::CommonLogger, file

run Coingate::API::WebSupport

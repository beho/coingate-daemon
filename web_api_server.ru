require_relative 'config/boot_web_api_server'

file = File.new("log/api_server.#{ENV['RACK_ENV']}.log", 'a+')
file.sync = true
use Rack::CommonLogger, file

run Coingate::API::WebSupport

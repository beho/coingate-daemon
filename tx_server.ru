require_relative 'config/boot_tx'

file = File.new("log/tx_server.#{ENV['RACK_ENV']}.log", 'a+')
file.sync = true
use Rack::CommonLogger, file

run Coingate::API::Tx

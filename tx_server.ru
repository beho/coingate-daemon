require_relative 'config/boot_tx_server'

file = File.new("log/tx_server.#{ENV['RACK_ENV']}.log", 'a+')
file.sync = true
use Rack::CommonLogger, file

run Coingate::API::Txs

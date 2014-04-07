#!/bin/sh

file = File.new("log/tx_server.#{ENV['RACK_ENV']}.log", 'a+')
file.sync = true
use Rack::CommonLogger, file

rackup -p 9393 tx_server.ru

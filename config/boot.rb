require 'rubygems'
require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

ENV['COINGATE_ROOT_PATH'] = File.expand_path( '..', File.dirname(__FILE__) )
ENV['COINGATE_LIB_PATH'] = File.expand_path( '../lib', File.dirname(__FILE__) )

$LOAD_PATH << ENV['COINGATE_ROOT_PATH'] << ENV['COINGATE_LIB_PATH']

require 'coingate'

require 'rubygems'
require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

root = File.expand_path( '..', File.dirname(__FILE__) )
lib = File.expand_path( '../lib', File.dirname(__FILE__) )

$LOAD_PATH << root << lib

require 'coingate'

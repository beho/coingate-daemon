require 'rubygems'
require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

require_relative 'config/app'
require_relative 'lib/coingate'

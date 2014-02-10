require 'rubygems'
require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

DB = Sequel.connect(YAML.load(File.read('./config/database.yml'))[ENV['RACK_ENV']])

require_relative '../lib/coingate'

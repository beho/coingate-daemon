require 'rubygems'
require 'bundler'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

root = File.expand_path( '../lib', File.dirname(__FILE__) )
$LOAD_PATH << root

DB = Sequel.connect( YAML.load( File.read( './config/database.yml' ) )[ENV['RACK_ENV']] )

COINS = {
  :btc => :Bitcoin
}

require 'coingate'

Coingate::Interop.initialize( YAML.load( File.read( './config/interop.yml' ) ) )
Coingate::Coin.initialize( COINS )

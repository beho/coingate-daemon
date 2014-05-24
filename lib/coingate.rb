require 'refinements'

require_relative 'services/progname_logger'

DB_CONFIG_FILENAME = 'database.yml'
INTEROP_CONFIG_FILENAME = 'interop.yml'
RABBITMQ_CONFIG_FILENAME = 'rabbitmq.yml'

QUEUE_NAME_TEMPLATE = "tx.%s"

module Coingate
  using Refinements

  class << self
    attr_reader :env, :config_base_dir
    attr_accessor :logger

    attr_reader :db_config, :interop_config, :rabbitmq_config, :rabbitmq_workers_config

    def tx_worker_config( altcoin )
      [tx_queue_name(altcoin), @rabbitmq_workers_config[:tx]]
    end

    def tx_queue_name( altcoin )
      QUEUE_NAME_TEMPLATE % altcoin.to_s
    end

    def initialize( config_base_dir = nil )
      @env = ENV['RACK_ENV'].to_sym
      @config_base_dir = config_base_dir || File.expand_path( '../config', File.dirname(__FILE__) )

      @db_config = load_config( DB_CONFIG_FILENAME )[@env]
      @interop_config = load_config( INTEROP_CONFIG_FILENAME )[@env]

      rabbitmq_full_config = load_config( RABBITMQ_CONFIG_FILENAME )[@env]
      @rabbitmq_workers_config = rabbitmq_full_config[:worker_types]

      rabbitmq_full_config.delete(:worker_types)
      @rabbitmq_config = rabbitmq_full_config

      # @logger = Logger.new( STDERR )
      # @logger_file = File.new( File.join( ENV['COINGATE_ROOT_PATH'], 'log', 'coingate.log' ), File::WRONLY | File::APPEND )
      # @logger_file.fsync = true

      @logger = PrognameLogger.new( ENV['COINGATE_PROCNAME'] || '?' )

      Sequel.default_timezone = :utc
      Sequel::Model.db = db

      # Interop.initialize( @interop_config )
      # Coin.initialize

      @logger.info( 'started' )

      self
    end

    def db
      @db ||= Sequel.connect( @db_config )
    end

  private
    def load_config( filename )
      path = File.join( @config_base_dir, filename )
      file = File.read( path )

      YAML.load( file ).with_symbol_keys
    end

  end
end

Coingate.initialize

Dir['./lib/models/**/*.rb'].each {|f| require f }

require_relative 'services/coin'
require_relative 'services/coins/bitcoin'
require_relative 'services/interop'

require_relative 'workers/base_tx_processor'
require_relative 'workers/tx_processors'

require_relative 'api/customers'
require_relative 'api/rates'
require_relative 'api/tx'
require_relative 'api/web_support'

# initialize rest of the services
Coingate::Interop.initialize( Coingate.interop_config )
Coingate::Coin.initialize

# Sequel DB global variable - implicitly used by models
# DB = Coingate.db

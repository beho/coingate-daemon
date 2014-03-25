module Coingate
  using Refinements

  class Interop
    def self.initialize( config )
      @@config = config.with_symbol_keys
    end

    def self.btc
      btc_config = @@config[:btc]
      Bitcoin::Client.new( btc_config[:username], btc_config[:password], host: btc_config[:host], port: btc_config[:port], ssl: btc_config[:ssl] )
    end
  end

end

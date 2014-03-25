module Coingate

  # mixin
  # requires instance methods: wallet_class, tx_class, new_address
  module Coind
    def self.initialize( coinds )
      @@mapping = Hash[coinds.map {|altcoin, daemon_class| [altcoin, Coingate.const_get( daemon_class ) ] }]
    end

    def self.for( altcoin )
      @@mapping[altcoin]
    end

    def new_wallet( customer_id, office_id )
      wallet_class.new( customer_id, office_id, new_address )
    end

  end

end

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
      wallet_class.create( customer_id: customer_id, office_id: office_id, pub_key: new_address )
    end

  end

end

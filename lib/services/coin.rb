module Coingate

  class Coin
    def self.initialize( coinds )
      @@mapping = Hash[coinds.map  do |altcoin, daemon_class|
        [altcoin, Coingate.const_get( daemon_class ) ]
      end]
    end

    def self.for( altcoin )
      @@mapping[altcoin].new
    end

    def create_wallet( customer, office_id, &block )
      wallet = Wallet.create(
        customer_id: customer.id,
        office_id: office_id,
        incoming_currency_id: currency_id,
        stored_currency_id: customer.default_currency_id
      )

      block.call( wallet )

      wallet
    end

    # for defining subclasses
    class << self
      def handles( currency_id, wallet_class, tx_class )
        instance_eval do
          define_method( :currency_id ) { currency_id }
          define_method( :wallet_class ) { wallet_class }
          define_method( :tx_class ) { tx_class }
        end
      end
    end

  end

end

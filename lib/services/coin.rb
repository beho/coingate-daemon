module Coingate

  class Coin
    def self.initialize( coinds )
      @@mapping = Hash[coinds.map do |altcoin, daemon_class|
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

    def wallet_for( address )
      wallet_class.first( address: address ).wallet
    end



    def create_or_confirm_transaction( txid, address, amount, tx_data )
      tx = tx_class.first( txid: txid )

      if tx.nil?
        create_transaction( txid, address, amount, tx_data )
      else
        confirm_transaction( tx, tx_data )
      end
    end

    def create_transaction( txid, address, amount, &block )
      wallet = wallet_for( address )
      rate = Rate.current( currency_id, wallet.stored_currency_id ).value
      fee = wallet.customer.fee_percent || Settings.fee_percent

      stored_amount = amount * rate * (1 + fee)

      transaction = Transaction.create(
        wallet_id: wallet.id,
        incoming_currency_id: currency_id,
        incoming_amount: amount,
        stored_currency_id: wallet.stored_currency_id,
        stored_amount: stored_amount,
        rate: rate,
        fee_percent: fee
      )

      block.call( transaction )

      transaction
    end


    def confirm_transaction( tx, &block )
      tx.update( :confirmed => true )

      block.call( tx )

      tx
    end

    # for defining subclasses
    class << self
      def handles( currency_id, wallet_class, tx_class )
        instance_eval do
          define_method( :currency_id ) { currency_id.to_s }
          define_method( :wallet_class ) { wallet_class }
          define_method( :tx_class ) { tx_class }
        end
      end
    end

  end

end

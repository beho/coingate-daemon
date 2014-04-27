module Coingate

  class Coin
    @@default_coins = {
      :btc => :Bitcoin
    }

    def self.initialize( coins = {} )
      @@mapping = Hash[@@default_coins.merge( coins ).map do |altcoin, daemon_class|
        [altcoin, Coingate.const_get( daemon_class ) ]
      end]
    end

    def self.for( altcoin )
      @@mapping[altcoin].new
    end



    def create_wallet( customer, office_id, address = nil )
      wallet = Wallet.create(
        customer_id: customer.id,
        office_id: office_id,
        incoming_currency_id: currency_id,
        address: address || new_address,
        stored_currency_id: customer.currency_id
      )
    end

    def create_or_confirm_payment( txid, tx_data )
      altcoin_payment = payment_class.first( txid: txid )

      if altcoin_payment.nil?
        address = tx_receiving_address( tx_data )
        amount = tx_amount( tx_data )

        create_payment( txid, address, amount, tx_data )
      else
        confirm_payment( altcoin_payment, tx_data )
      end
    end

    def create_payment( txid, address, amount, &block )
      wallet = Wallet.first( address: address )
      rate = Rate.current( currency_id, wallet.stored_currency_id ).value
      fee_percent = wallet.customer.fee_percent || Settings.fee_percent

      target_amount = rate * amount

      payment = Payment.create(
        wallet_id: wallet.id,
        source_currency_id: currency_id,
        source_amount: amount,
        target_currency_id: wallet.stored_currency_id,
        target_amount: target_amount,
        rate: rate,
        fee_percent: fee_percent
      )

      block.call( payment )

      payment
    end


    def confirm_payment( payment, &block )
      payment.confirm! unless payment.confirmed?

      block.call( payment )

      payment
    end

    # for defining subclasses
    class << self
      def handles( currency_id, payment_class )
        # instance_eval do
          define_method( :currency_id ) { currency_id.to_s }
          define_method( :payment_class ) { payment_class }
        # end
      end
    end

  end

end

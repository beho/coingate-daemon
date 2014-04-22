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



    def create_wallet( customer, office_id, &block )
      wallet = Wallet.create(
        customer_id: customer.id,
        office_id: office_id,
        incoming_currency_id: currency_id,
        stored_currency_id: customer.currency_id
      )

      wallet_data = block.call( wallet )

      [wallet, wallet_data]
    end

    def wallet_for( address )
      puts address
      wallet_class.first( address: address ).wallet
    end



    def create_or_confirm_payment( txid, address, amount, tx_data )
      altcoin_tx = tx_class.first( txid: txid )

      if altcoin_tx.nil?
        create_payment( txid, address, amount, tx_data )
      else
        confirm_payment( altcoin_tx.payment, tx_data )
      end
    end

    def create_payment( txid, address, amount, &block )
      wallet = wallet_for( address )
      rate = Rate.current( currency_id, wallet.stored_currency_id ).value
      fee = wallet.customer.fee_percent || Settings.fee_percent

      stored_amount, fee = Payment.split_incoming_amount( amount, rate, fee )

      payment = Payment.create(
        wallet_id: wallet.id,
        source_currency_id: currency_id,
        source_amount: amount,
        target_currency_id: wallet.stored_currency_id,
        target_amount: stored_amount,
        rate: rate,
        fee_percent: fee
      )

      block.call( payment )

      payment
    end


    def confirm_payment( payment, &block )
      source_income, source_fee = payment.split_source_amount
      target_income, target_fee = payment.split_target_amount

      income_transaction = Transaction.create(
        customer_id: payment.wallet.customer_id,
        source_currency_id: payment.source_currency_id,
        source_amount: source_income,
        target_currency_id: payment.target_currency_id,
        target_amount: target_income
      )

      fee_transaction = Transaction.create(
        customer_id: Settings.system_customer_id,
        source_currency_id: payment.source_currency_id,
        source_amount: source_fee,
        target_currency_id: payment.target_currency_id,
        target_amount: target_fee
      )

      payment.update( transaction_id: income_transaction.id, fee_transaction_id: fee_transaction.id )

      block.call( payment )

      payment
    end

    # for defining subclasses
    class << self
      def handles( currency_id, wallet_class, payment_class )
        # instance_eval do
          define_method( :currency_id ) { currency_id.to_s }
          define_method( :wallet_class ) { wallet_class }
          define_method( :payment_class ) { payment_class }
        # end
      end
    end

  end

end

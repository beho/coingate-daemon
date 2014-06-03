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
      Wallet.create(
        customer_id: customer.id,
        office_id: office_id,
        incoming_currency_id: currency_id,
        address: address || new_address,
        stored_currency_id: customer.currency_id
      )
    end

    def get_tx_and_process( txid )
      tx = tx( txid )

      process( tx )
    end

    def process( tx )
      return unless tx.received?

      payment = Coingate.db.transaction( :isolation => :serializable ) do
        altcoin_payment = payment_class.first( txid: tx.txid )

        altcoin_payment.nil? ? create_payment( tx ) : altcoin_payment.payment
      end

      payment.confirm! if tx.confirmed?
      payment.invalidate! if tx.invalid?

      payment
    end

    def create_payment( tx, &block )
      wallet = Wallet.first( incoming_currency_id: tx.currency_id, address: tx.address ) ||
        Settings.system_customer.wallets_dataset.first( incoming_currency_id: tx.currency_id )

      rate = Rate.current( tx.currency_id, wallet.stored_currency_id ).value
      fee_percent = wallet.customer.current_fee_percent

      target_amount = rate * tx.amount

      payment = Payment.create(
        wallet_id: wallet.id,
        source_currency_id: wallet.incoming_currency_id,
        source_amount: tx.amount,
        target_currency_id: wallet.stored_currency_id,
        target_amount: target_amount,
        rate: rate,
        fee_percent: fee_percent
      )

      block.call( payment )

      Coingate.logger.info( "created BTC payment[id: #{payment.id}] for customer[id: #{wallet.customer.id}]" )

      payment
    end

    def process_txs_since_last_checkpoint
      checkpoint = Checkpoint[currency_id] || Checkpoint.create( currency_id: currency_id, blockhash: best_block_hash )
      
      process_txs_since( checkpoint )
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

    class Tx
      attr_reader :currency_id, :txid, :address, :amount, :status

      def initialize( currency_id, txid, address, amount, received, confirmations )
        @currency_id = currency_id
        @txid = txid
        @address = address
        @amount = amount
        @received = received

        @status =
          if confirmations == -1
            :invalid
          elsif confirmations > 5
            :confirmed
          else
            :pending
          end
      end

      def received?
        @received
      end

      def confirmed?
        @status == :confirmed
      end

      def invalid?
        @status == :invalid
      end
    end

  end

end

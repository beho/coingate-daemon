module Coingate

  class Bitcoin < Coin
    handles :BTC, BtcPayment

    def new_address
      Interop.btc.getnewaddress
    end

    def tx( txid )
      tx_data = Interop.btc.gettransaction( txid )

      details = tx_data['details'][0]

      received = details['category'] == 'receive'
      address = details['address']
      amount = details['amount']
      confirmed = tx_data['confirmations'] > 0

      Tx.new( currency_id, txid, address, amount, received, confirmed )
    end

    def create_payment( tx )
      super( tx ) do |payment|
        payment_class.create( payment_id: payment.id, txid: tx.txid )
      end
    end

    # def confirm_payment( btc_payment, tx )
    #   if tx.confirmations > 0
    #     super( btc_payment.payment ) do
    #       btc_payment.update( :confirmations => tx.confirmations )
    #     end
    #   end
    # end


    # class Tx < Coin::Tx
    #   def self.get( txid )
    #     self.new( Interop.btc.gettransaction( txid ) )
    #   end

    #   def initialize( tx_data )
    #     details = tx_data['details'][0]

    #     @txid = tx_data['txid']
    #     @received = details['category'] == 'receive'
    #     @address = details['address']
    #     @amount = details['amount']
    #   end
    # end

  end

end

# TX example
#
# {
#   "amount"=>0.0,
#   "confirmations"=>0,
#   "generated"=>true,
#   "txid"=>"36f0bc5ac860499f59fe92acd34bc479a28eaa02aacb2dfc5ab2dbe6c256f6ee",
#   "time"=>1390628962,
#   "timereceived"=>1390628962,
#   "details"=>[{
#     "account"=>"",
#     "address"=>"mktDHHMkvW9toTocYygih8bRoEu6wR8zgt",
#     "category"=>"orphan",
#     "amount"=>50.0005
#   }]
# }

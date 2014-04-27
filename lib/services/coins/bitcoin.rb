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

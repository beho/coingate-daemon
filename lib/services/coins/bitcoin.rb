module Coingate

  class Bitcoin < Coin
    handles :BTC, BtcPayment

    def new_address
      Interop.btc.getnewaddress
    end

    def get_tx_data( txid )
      Interop.btc.gettransaction( txid )
    end

    def tx_is_received?( tx_data )
      tx_data['details'][0]['category'] == 'receive'
    end

    def tx_receiving_address( tx_data )
      tx_data['details'][0]['address']
    end

    def tx_amount( tx_data )
      tx_data['details'][0]['amount']
    end

    def create_payment( txid, address, amount, tx_data )
      super( txid, address, amount ) do |tx|
        payment_class.create( payment_id: tx.id, txid: txid, confirmations: tx_data['confirmations'] )
      end
    end

    def confirm_payment( btc_payment, tx_data )
      confirmations = tx_data['confirmations']

      return if confirmations == 0

      super( btc_payment.payment ) do
        btc_payment.update( :confirmations => tx_data['confirmations'] )
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

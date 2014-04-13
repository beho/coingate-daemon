module Coingate

  class Bitcoin < Coin
    handles :BTC, BtcWallet, BtcTransaction

    def new_address
      Interop.btc.getnewaddress
    end

    def get_tx( txid )
      Interop.btc.gettransaction( txid )
    end

    def create_wallet( customer, office_id, address = nil )
      super( customer, office_id ) do |wallet|
        wallet_class.create( wallet_id: wallet.id, address: address || new_address )
      end
    end

    def create_or_confirm_transaction( txid )
      tx_data = get_tx( txid )

      tx_details = tx_data['details'][0]
      address = tx_details['address']
      amount = tx_details['amount']

      puts amount
      super( txid, address, amount, tx_data )
    end

    def create_transaction( txid, address, amount, tx_data )
      super( txid, address, amount ) do |tx|
        tx_class.create( transaction_id: tx.id, txid: txid, confirmations: tx_data['confirmations'] )
      end
    end

    def confirm_transaction( tx, tx_data )
      super( tx ) do
        tx_class[tx.id].update( :confirmations => tx_data['confirmations'] )
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

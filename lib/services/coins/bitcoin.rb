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
      confirmations = tx_data['confirmations']

      Tx.new( currency_id, txid, address, amount, received, confirmations )
    end

    def create_payment( tx )
      super( tx ) do |payment|
        payment_class.create( payment_id: payment.id, txid: tx.txid )
      end
    end

    def best_block_hash
      Interop.btc.bestblockhash
    end

    def process_txs_since( checkpoint )
      block = Interop.btc.getblock( checkpoint.blockhash )
      since_checkpoint = Interop.btc.listsinceblock( checkpoint.blockhash )

      Coingate.logger.info( "BTC - processing txs since #{checkpoint.blockhash}" )

      since_checkpoint['transactions'].each do |tx|
        get_tx_and_process( tx['txid'] ) if tx['category'] == 'receive'
      end

      if block['confirmations'] != -1
        checkpoint.update( blockhash: since_checkpoint['lastblock'] )

        Coingate.logger.info( "BTC - new checkpoint blockhash #{checkpoint.blockhash}" )
      else
        checkpoint.last_blockhash = block.previousblockhash

        Coingate.logger.warn( "BTC - invalid block; backtracking to #{checkpoint.blockhash}" )

        process_txs_since( checkpoint )
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

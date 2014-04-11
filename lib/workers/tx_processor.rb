class TxProcessor
  include Sneakers::Worker
  from_queue 'txs.btc'

  def work( txid )
    Coingate::Bitcoin.new.create_or_confirm_transaction( txid )

    # Coingate::Bitcoin.create_or_confirm_transaction( address, amount, txid, tx_data )

    ack!
  end
end

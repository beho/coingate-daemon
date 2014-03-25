class TxProcessor
  include Sneakers::Worker
  from_queue 'coingate.tx'

  def work( msg )
    # tx_id = JSON.parse( msg )['txid']

    puts msg
    # put into db or whatever
    ack!
  end
end

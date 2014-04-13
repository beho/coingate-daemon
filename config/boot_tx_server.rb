require_relative 'boot'

MQ_CONN = Bunny.new
MQ_CONN.start

BTC_QUEUE = Coingate.tx_queue_name( :btc )
XPM_QUEUE = Coingate.tx_queue_name( :xpm )

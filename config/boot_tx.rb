require_relative 'boot'

MQ_CONN = Bunny.new
MQ_CONN.start

BTC_QUEUE = 'txs.btc'
XPM_QUEUE = 'txs.xpm'

# MQ_CONN.create_channel.queue( BTC_QUEUE )
# MQ_CONN.create_channel.queue( XPM_QUEUE )

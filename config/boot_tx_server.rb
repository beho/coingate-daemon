ENV['COINGATE_PROCNAME'] = 'tx_processor'

require_relative 'boot'

MQ_CONN = Bunny.new
MQ_CONN.start

EXCHANGE = Coingate.rabbitmq_workers_config[:tx][:exchange]

BTC_QUEUE = Coingate.tx_queue_name( :btc )
XPM_QUEUE = Coingate.tx_queue_name( :xpm )

ENV['COINGATE_PROCNAME'] = 'tx_processor'

require_relative 'boot'
require 'sneakers/runner'

Sneakers.configure( Coingate.rabbitmq_config )

r = Sneakers::Runner.new( [BtcTxProcessor] )
r.run

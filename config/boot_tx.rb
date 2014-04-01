require_relative 'boot'

MQ_CONN = Bunny.new
MQ_CONN.start

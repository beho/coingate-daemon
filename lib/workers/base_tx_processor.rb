class BaseTxProcessor
  include Sneakers::Worker

  def work( txid )
    coin = Coingate::Coin.for( self.class.altcoin )
    tx_data = coin.get_tx_data( txid )

    coin.create_or_confirm_transaction( txid ) if coin.is_received_tx?( tx_data )

    ack!
  end

  class << self
    attr_reader :altcoin

    def handles( altcoin )
      @altcoin = altcoin
      @queue_name, @queue_opts = Coingate.tx_worker_config( altcoin )
    end
  end

end

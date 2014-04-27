class BaseTxProcessor
  include Sneakers::Worker

  def work( txid )
    coin = Coingate::Coin.for( self.class.altcoin )

    coin.get_tx_and_process( txid )

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

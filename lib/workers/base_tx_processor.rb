class BaseTxProcessor
  include Sneakers::Worker

  def work( txid )
    Coingate::Coin.for( self.class.altcoin ).create_or_confirm_transaction( txid )

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

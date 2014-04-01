module Coingate

  module Bitcoind
    include Coingate::Coind

    def wallet_class
      BTC::Wallet
    end

    def wallet_class
      BTC::Tx
    end

    def new_address
      Interop.btc.getnewaddress
    end
  end

end

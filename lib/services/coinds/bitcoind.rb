module Coingate

  class Bitcoind
    include Coingate::Coind

    def wallet_class
      BtcWallet
    end

    def tx_class
      BtcTx
    end

    def new_address
      Interop.btc.getnewaddress
    end
  end

end

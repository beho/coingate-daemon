module Coingate

  class Bitcoin < Coin
    handles :BTC, BtcWallet, BtcTransaction

    def create_wallet( customer_id, office_id )
      super( customer_id, office_id ) do |wallet|
        wallet_class.create( wallet_id: wallet.id, pub_key: new_address )
      end
    end

    def new_address
      Interop.btc.getnewaddress
    end
  end

end

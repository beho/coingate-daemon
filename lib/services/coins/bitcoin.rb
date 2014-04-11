module Coingate

  class Bitcoin < Coin
    handles :BTC, BtcWallet, BtcTransaction

    def new_address
      Interop.btc.getnewaddress
    end

    def get_tx( txid )
      Interop.btc.gettransaction( txid )
    end

    def create_wallet( customer, office_id, address = nil )
      super( customer, office_id ) do |wallet|
        wallet_class.create( wallet_id: wallet.id, address: address || new_address )
      end
    end

    def create_or_confirm_transaction( txid )
      tx = get_tx( txid )

      address = tx['address']
      amount = tx['amount'].to_f

      super( txid, address, amount, tx )
    end

    def create_transaction( txid, address, amount, tx_data )
      super( txid, address, amount ) do |tx|
        tx_class.create( transaction_id: tx.id, txid: txid, confirmations: tx_data[:confirmations] )
      end
    end

    def confirm_transaction( tx, tx_data )
      super( tx ) do
        tx_class[tx.id].update( :confirmations => tx_data[:confirmations] )

        wallet = tx.wallet
        wallet.update(
          :incoming_amount => wallet.incoming_amount + tx.incoming_amount,
          :stored_amount => wallet.stored_amount + tx.stored_amount,
          :confirmed => true )
      end
    end

  end

end

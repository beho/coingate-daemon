class BtcTx < Sequel::Model( :btc_txs )
  many_to_one :wallet, :class => :Wallet
  plugin :timestamps
end

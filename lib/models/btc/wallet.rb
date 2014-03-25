class BtcWallet < Sequel::Model( :btc_wallets )
  one_to_many :txs, :class => :BtcTx
  plugin :timestamps
end

class BtcWallet < Sequel::Model( :btc_wallets )
  unrestrict_primary_key

  one_to_one :wallet
end

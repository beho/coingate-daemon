class BtcWallet < Sequel::Model( :btc_wallets )
  unrestrict_primary_key

  # TODO should be one to one but!
  many_to_one :wallet
end

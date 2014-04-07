class BtcTransaction < Sequel::Model( :btc_transactions )
  unrestrict_primary_key

  one_to_one :transaction
end

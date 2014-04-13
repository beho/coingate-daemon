class BtcTransaction < Sequel::Model( :btc_transactions )
  unrestrict_primary_key

  # TODO should be one to one but!
  many_to_one :transaction
end

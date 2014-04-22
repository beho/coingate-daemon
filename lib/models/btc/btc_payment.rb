class BtcPayment < Sequel::Model( :btc_payments )
  unrestrict_primary_key

  # TODO should be one to one but!
  many_to_one :payment
end

class Transaction < Sequel::Model( :transactions )
  many_to_one :wallet

  plugin :timestamps
end

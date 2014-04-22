class Transaction < Sequel::Model( :transactions )
  plugin :timestamps
end

class Wallet < Sequel::Model( :wallets )
  one_to_many :transactions
  plugin :timestamps
end

class Wallet < Sequel::Model( :wallets )
  one_to_many :transactions
  many_to_one :customer

  plugin :timestamps
end

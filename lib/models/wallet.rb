class Wallet < Sequel::Model( :wallets )
  one_to_many :transactions
  many_to_one :customer

  plugin :timestamps

  def compute_balance
    balance = transactions_dataset.get{ [sum(incoming_amount).as(incoming), sum(stored_amount).as(stored)] }
    [balance[0] || 0, balance[1] || 0]
  end

  def update_balance
    self.class.db.transaction do
      incoming, stored = compute_balance

      update( incoming_amount: incoming, stored_amount: stored )
    end
  end
end

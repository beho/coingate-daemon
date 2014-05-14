class Customer < Sequel::Model(:customers)
  unrestrict_primary_key

  one_to_many :wallets
  one_to_many :payments
  one_to_many :transactions, :order => :created_at

  plugin :timestamps

  # balance in real currency
  def balance
    last_transaction = transactions_dataset.last
    last_transaction ? last_transaction.target_amount : 0
  end

  def altcoin_balance(altcoin)
    last_transaction = transactions_dataset.where( source_currency_id: altcoin ).last
    last_transaction ? last_transaction.source_amount : 0
  end

  def create_transaction( source_currency_id, source_amount, rate, office_id = nil )
    target_amount = rate * source_amount

    self.class.db.transaction do
      Transaction.create(
        customer_id: id,
        office_id: office_id,
        source_currency_id: source_currency_id,
        source_amount: source_amount,
        target_currency_id: currency_id,
        target_amount: target_amount,
        rate: rate,
        source_balance: altcoin_balance(source_currency_id) + source_amount,
        target_balance: balance + target_amount
      )
    end
  end

  def incomes_dataset
    transactions_dataset.incomes
  end
end

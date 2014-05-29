class Customer < Sequel::Model(:customers)
  unrestrict_primary_key

  one_to_many :wallets
  one_to_many :payments, :order => :created_at
  one_to_many :transactions

  plugin :timestamps

  def current_fee_percent
    fee_percent || Settings.fee_percent
  end

  # balance in real currency
  def balance
    last_transaction = transactions_dataset.ordered.last
    last_transaction ? last_transaction.target_balance : 0
  end

  def altcoin_balance( altcoin )
    last_transaction = transactions_dataset.where( source_currency_id: altcoin ).ordered.last
    last_transaction ? last_transaction.source_balance : 0
  end

  # reuses transaction if in one otherwise creates a new transaction
  def create_transaction( source_currency_id, source_amount, rate, office_id = nil )
    if self.class.db.in_transaction?
      create_transaction_bare( source_currency_id, source_amount, rate, office_id )
    else
      self.class.db.transaction( :isolation => :serializable, :retry_on => [Sequel::SerializationFailure] ) do
        create_transaction_bare( source_currency_id, source_amount, rate, office_id )
      end
    end
  end

  def incomes_dataset
    transactions_dataset.incomes
  end

  private
  def create_transaction_bare( source_currency_id, source_amount, rate, office_id = nil )
    target_amount = rate * source_amount

    target_balance = balance
    source_balance = altcoin_balance( source_currency_id )

    Transaction.create(
      customer_id: id,
      office_id: office_id,
      source_currency_id: source_currency_id,
      source_amount: source_amount,
      target_currency_id: currency_id,
      target_amount: target_amount,
      rate: rate,
      source_balance: source_balance + source_amount,
      target_balance: target_balance + target_amount
    )
  end
end

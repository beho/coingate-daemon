Sequel.migration do
  up do
    create_table :currencies do
      String :id, size: 3, primary_key: true
      String :name, size: 16
      TrueClass :is_virtual
    end

    create_table :markets do
      Integer :id, primary_key: true
      String :name, size: 16
    end

    create_table :customers do
      Integer :id, primary_key: true

      String :name, size: 32

      foreign_key :currency_id, :currencies, type: 'char(3)', null: false
      Decimal :fee_percent, size: [19, 4]

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :rates do
      foreign_key :source_currency_id, :currencies, type: 'char(3)'
      foreign_key :target_currency_id, :currencies, type: 'char(3)'
      foreign_key :market_id, :markets
      DateTime :at

      BigDecimal :value, size: [19, 4]

      primary_key [:market_id, :source_currency_id, :target_currency_id, :at]
    end

    create_table :wallets do
      primary_key :id

      foreign_key :customer_id, :customers
      Integer :office_id

      foreign_key :incoming_currency_id, :currencies, type: 'char(3)'
      String :address, size: 64

      # BigDecimal :incoming_amount, size: [19, 8], default: 0

      foreign_key :stored_currency_id, :currencies, type: 'char(3)'
      # BigDecimal :stored_amount, size: [19, 8], default: 0

      DateTime :created_at
      DateTime :updated_at

      index [:customer_id, :office_id, :incoming_currency_id]
    end

    create_table :payments do
      primary_key :id

      foreign_key :wallet_id, :wallets, index: true

      foreign_key :source_currency_id, :currencies, type: 'char(3)'
      BigDecimal :source_amount, size: [19, 8]

      foreign_key :target_currency_id, :currencies, type: 'char(3)'
      BigDecimal :target_amount, size: [19, 8]

      BigDecimal :rate, size: [19, 4]
      BigDecimal :fee_percent, size: [19, 4]

      foreign_key :transaction_id, :transactions
      foreign_key :fee_transaction_id, :transactions

      DateTime :created_at
      DateTime :confirmed_at
      DateTime :updated_at
    end

    create_table :withdrawals do
      primary_key :id

      foreign_key :customer_id, :customers

      TrueClass :in_stored_currency, default: true
      BigDecimal :amount, size: [19, 8]

      foreign_key :created_at
      foreign_key :updated_at
    end

    create_table :transactions do
      primary_key :id

      foreign_key :customer_id, :customers
      Integer :office_id

      foreign_key :source_currency_id, :currencies, type: 'char(3)'
      BigDecimal :source_amount, size: [19, 8]

      foreign_key :target_currency_id, :currencies, type: 'char(3)'
      BigDecimal :target_amount, size: [19, 8]

      BigDecimal :rate, size: [19, 4]

      BigDecimal :source_balance, size: [19, 8]
      BigDecimal :target_balance, size: [19, 8]

      DateTime :created_at

      index [:customer_id, :office_id]
    end

    create_join_table(:withdrawal_id => :withdrawals, :transaction_id => :transactions)

    create_table :settings do
      Integer :id, primary_key: true

      foreign_key :system_customer_id, :customers
      BigDecimal :fee_percent, size: [19, 4]
    end

  end

  down do
    drop_table(:settings, :transactions_withdrawals, :transactions, :withdrawals, :payments, :wallets, :rates, :customers, :markets, :currencies)
  end
end

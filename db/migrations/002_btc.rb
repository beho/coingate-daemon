Sequel.migration do
  up do
    create_table :btc_wallets do
      primary_key :id

      foreign_key :customer_id, :customers
      Integer :office_id
      String :pub_key, size: 34

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :btc_txs do
      primary_key :id

      foreign_key :btc_wallet_id, :btc_wallets
      Integer :confirmations

      BigDecimal :amount, size: [19, 8] # precision for 1 satoshi
      foreign_key :real_currency_id, :currencies, type: 'char(3)'
      BigDecimal :rate, size: [19, 4]
      BigDecimal :fee_percent, size: [19, 8], null: true

      DateTime :created_at
      DateTime :updated_at
    end

    create_table :btc_input_addresses do
      foreign_key :btc_tx_id, :btc_txs
      String :pub_key, size: 34
    end

  end

  down do
    drop_table(:btc_input_addresses, :btc_txs, :btc_wallets)
  end
end

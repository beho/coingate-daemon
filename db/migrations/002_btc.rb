Sequel.migration do
  up do
    create_table :btc_wallets do
      foreign_key :wallet_id, :wallets, primary_key: true

      String :pub_key, size: 34
    end

    create_table :btc_transactions do
      foreign_key :transaction_id, :transactions, primary_key: true

      Integer :confirmations
    end

    create_table :btc_input_addresses do
      foreign_key :btc_transaction_id, :btc_transactions
      String :pub_key, size: 34
    end

  end

  down do
    drop_table(:btc_input_addresses, :btc_transactions, :btc_wallets)
  end
end

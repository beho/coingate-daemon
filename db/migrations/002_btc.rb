Sequel.migration do
  up do
    # create_table :btc_wallets do
    #   foreign_key :wallet_id, :wallets, primary_key: true

    #   String :address, size: 34
    # end

    create_table :btc_payments do
      String :txid, size: 64, primary_key: true

      foreign_key :payment_id, :payments, index: true
    end

    # create_table :btc_input_addresses do
    #   foreign_key :btc_payment_id, :btc_payments
    #   String :address, size: 34
    # end

  end

  down do
    drop_table(:btc_payments)
  end
end

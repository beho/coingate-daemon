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
      primary_key :id

      foreign_key :default_currency_id, :currencies
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
  end

  down do
    drop_table(:rates, :customers, :markets, :currencies)
  end
end

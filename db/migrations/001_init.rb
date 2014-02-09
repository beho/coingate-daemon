Sequel.migration do
  up do
    create_table :currencies do
      String :id, primary_key: true, size: 3, fixed: true
      String :name, length: 16
    end

    create_table :markets do
      Integer :id, primary_key: true
      String :name, length: 16
    end

    create_table :rates do
      foreign_key :source_currency_id, :currencies, type: 'char(3)'
      foreign_key :target_currency_id, :currencies, type: 'char(3)'
      foreign_key :market_id, :markets
      DateTime :at

      BigDecimal :buy, size: [19, 4]
      BigDecimal :sell, size: [19, 4]
      BigDecimal :low, size: [19, 4]
      BigDecimal :high, size: [19, 4]
      BigDecimal :avg, size: [19, 4]

      primary_key [:market_id, :source_currency_id, :target_currency_id, :at]
    end
  end

  down do
    drop_table(:rates, :markets, :currencies)
  end
end

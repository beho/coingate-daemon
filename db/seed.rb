require_relative '../config/boot'

include Coingate

if Currency.empty?
  Currency.import([:id, :name, :is_virtual], [
    ['CZK', 'Česká Koruna', false],
    ['EUR', 'Euro', false],
    ['USD', 'Americký Dolar', false],
    ['BTC', 'Bitcoin', true]])
end

if Market.empty?
  Market.import([:id, :name],
    [[1, 'Internal']])
end

if Rate.empty?
  Rate.import([:source_currency_id, :target_currency_id, :market_id, :at, :value], [
    ['BTC', 'CZK', 1, Time.now.utc, 11450],
    ['BTC', 'EUR', 1, Time.now.utc, 450]])
end

if Settings.empty?
  Settings.import([:id, :fee_percent], [
    [1, 0.08]])
end

if Customer.empty?
  system = Customer.create( id: 0, name: 'coingate', currency_id: 'CZK', fee_percent: 0)
  Settings.instance.update( system_customer_id: system.id )
end

require_relative '../config/boot'

include Coingate

Currency.import([:id, :name, :is_virtual], [
  ['CZK', 'Česká Koruna', false],
  ['EUR', 'Euro', false],
  ['USD', 'Americký Dolar', false],
  ['BTC', 'Bitcoin', true]])

Market.import([:id, :name],
  [[1, 'Internal']])

Rate.import([:source_currency_id, :target_currency_id, :market_id, :at, :value], [
  ['BTC', 'CZK', 1, Time.now.utc, 11450]])



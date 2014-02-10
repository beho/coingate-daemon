require_relative '../config/app'

Currency.import([:id, :name],
  [['BTC', 'Bitcoin'],
  ['EUR', 'Euro'],
  ['CZK', 'Česká Koruna']])

Market.import([:id, :name],
  [[1, 'Mtgox']])

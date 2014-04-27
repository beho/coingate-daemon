require_relative '../../config/boot'

include Coingate


test_customer = Customer.create( id: 1, name: 'test', currency_id: 'CZK', fee_percent: 0.05)

Coin.for(:btc).create_wallet( test_customer, 1, 'test_address')

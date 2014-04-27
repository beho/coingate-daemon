require 'minitest/autorun'

describe Coin do
  before do
    @coin = Coin.new
  end
end


# Coingate::Coin.for(:btc).create_or_confirm_payment('tx_2', {'details' => [{'address' => 'test_address', 'amount' => 0.05}], 'confirmations' => 1})

require 'spec_helper'

include Coingate

AMOUNT = BigDecimal.new('0.01')
FEE = BigDecimal.new('0.1')
ADDRESS = '123456abcd'

describe Bitcoin do
  before do
    @coin = Coingate::Bitcoin.new
    @customer = Customer.create( id: 100, currency_id: 'CZK', fee_percent: FEE )
    @wallet = Wallet.create(
      customer_id: @customer.id,
      office_id: 1,
      incoming_currency_id: 'BTC',
      address: ADDRESS,
      stored_currency_id: @customer.currency_id )
  end

  it "creates an unconfirmed payment for unconfirmed receive tx" do
    tx = Coin::Tx.new( 'BTC', 'tx_1', ADDRESS, 0.01, true, false )
    payment = @coin.process( tx )

    expect( payment.confirmed? ).to be false
  end

  it "does not create a payment for non-receive tx" do
    # unconfirmed
    tx1 = Coin::Tx.new( 'BTC', 'tx_1', ADDRESS, 0.01, false, false )
    payment1 = @coin.process( tx1 )

    expect( payment1 ).to be_nil

    # confirmed
    tx2 = Coin::Tx.new( 'BTC', 'tx_2', ADDRESS, 0.01, false, true )
    payment2 = @coin.process( tx2 )

    expect( payment2 ).to be_nil
  end

  it "confirms a payment if a tx is confirmed" do
    tx = Coin::Tx.new( 'BTC', 'tx_1', ADDRESS, 0.01, true, true )
    payment = @coin.process( tx )

    expect( payment.confirmed? ).to be true
  end

  it "splits a confirmed payment correctly into two transactions if fee_percent is non-zero" do
    tx = Coin::Tx.new( 'BTC', 'tx_1', ADDRESS, AMOUNT, true, true )
    payment = @coin.process( tx )

    # expect( payment.transaction.source_amount ).to eq( 0.01 * (1 - 0.1) )
    expect( payment.transaction.source_amount ).to eq( AMOUNT * (1 - FEE) )
    expect( payment.fee_transaction.source_amount ).to eq( AMOUNT * FEE )
  end

  it 'does not create fee_transaction for a confirmed payment if fee_percent is 0' do
    @customer.update( fee_percent: 0 )

    tx = Coin::Tx.new( 'BTC', 'tx_1', ADDRESS, AMOUNT, true, true )
    payment = @coin.process( tx )

    expect( payment.transaction ).to be_truthy
    expect( payment.fee_transaction ).to be nil
  end


end

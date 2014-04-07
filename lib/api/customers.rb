module Coingate
module API

  class Customers < Grape::API

    resources :customers do

      params do
        requires :customer_id, type: Integer, desc: 'Customer id.'
      end
      resource ':customer_id' do

        resources :wallets do

          params do
            requires :altcoin, type: String, desc: 'Altcoin identifier.'
            requires :office_id, type: Integer, desc: 'Office id'
            optional :in, type: String, default: :CZK, desc: 'Real currency of the wallet'
          end
          resource ':altcoin' do

            post do
              altcoin = params[:altcoin].downcase.to_sym

              customer = Customer.find_or_create( id: params[:customer_id] ) do |c|
                c.default_currency_id = params[:in]
              end

              wallet = Coingate::Coin.for( altcoin ).create_wallet( customer, params[:office_id] )

              wallet.to_hash
            end

            get 'txs' do
              # { altcoin: 'BTC', created_at: , confirmed_at:, amount: }
            end

          end

          get 'fee' do
            customer = Customer[params[:customer_id]]

            error!(404, 'Not found') unless customer

            customer.fee_percent
          end
        end

      end

      # change fee
    end

  end

end
end

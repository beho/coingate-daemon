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
          end
          resource ':altcoin' do

            post do
              altcoin = params[:altcoin].downcase.to_sym

              wallet = Coind.for( altcoin ).new_wallet( customer_id, office_id )
              wallet.save

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

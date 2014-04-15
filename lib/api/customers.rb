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

              wallet, wallet_data = Coingate::Coin.for( altcoin ).create_wallet( customer, params[:office_id] )

              wallet_hash = wallet.to_hash
              wallet_hash[:address] = wallet_data[:address]

              wallet_hash
            end

          end

          get 'fee' do
            customer = Customer[params[:customer_id]]

            error!(404, 'Not found') unless customer

            customer.fee_percent
          end

        end

        params do
          optional :since
          optional :until
          optional :office_id
        end
        get 'txs' do
          txs = Transaction.join(Wallet, :id => :wallet_id)
            .where( customer_id: params[:customer_id] )
            .select_all( :transactions )
            .order( Sequel.desc(:transactions__created_at) )

          since_timepoint = params[:since] ? Time.parse( params[:since] ) : nil
          until_timepoint = params[:until] ? Time.parse( params[:until] ) : nil

          txs = txs.where( office_id: params[:office_id] ) if params[:office_id]
          txs = txs.where{ transactions__created_at >= since_timepoint } if since_timepoint
          txs = txs.where{ transactions__created_at <= until_timepoint } if until_timepoint

          txs.map(&:to_hash)
        end

      end

      # change fee
    end

  end

end
end

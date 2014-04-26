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
            optional :in, type: String, default: :CZK, desc: 'Real currency of the wallet'
          end
          resource ':altcoin' do

            params do
              optional :office_id, type: Integer, desc: 'Office id'
            end
            get do
              customer = Customer[params[:customer_id]]
              error!(404, 'Not found') unless customer

              altcoin = params[:altcoin]
              office_id = params[:office_id]

              wallets = customer.wallets_dataset
              wallets = wallets.where( incoming_currency_id: altcoin.upcase ) if altcoin
              wallets = wallets.where( office_id: params[:office_id] ) if office_id

              wallets.map do |w|
                { id: w.id, currency: w.incoming_currency_id, address: w.address, office_id: office_id }
              end
            end

            params do
              requires :office_id, type: Integer, desc: 'Office id'
            end
            post do
              altcoin = params[:altcoin].downcase.to_sym

              customer = Customer.find_or_create( id: params[:customer_id] ) do |c|
                c.currency_id = params[:in]
              end

              wallet, wallet_data = Coingate::Coin.for( altcoin ).create_wallet( customer, params[:office_id] )

              status 201
              { id: wallet.id, currency: wallet.incoming_currency_id, address: wallet_data.address }
            end

          end

        end

        get 'fee' do
          customer = Customer[params[:customer_id]]
          error!(404, 'Not found') unless customer

          customer.fee_percent.to_f
        end

        get 'balance' do
          customer = Customer[params[:customer_id]]
          error!(404, 'Not found') unless customer

          customer.balance.to_f
        end

        params do
          optional :office_id
          optional :since
          optional :until
        end
        resource 'incomes' do
          get do
            customer = Customer[params[:customer_id]]
            error!(404, 'Not found') unless customer

            office_id = params[:office_id]
            since_timepoint = params[:since] ? Time.parse( params[:since] ) : nil
            until_timepoint = params[:until] ? Time.parse( params[:until] ) : nil

            incomes = customer.transactions_dataset.incomes
            incomes = incomes.in_time_interval( since_timepoint, until_timepoint )

            source_amount, target_amount = incomes.amount_sums

            incomes = incomes.where( office_id: office_id ) if office_id
            offices = incomes
              .group(:office_id)
              .select_append { sum(target_amount).as(target) }
              .select_append { sum(source_amount).as(source) }
              .map {|o| { office_id: o.office_id, amount: o[:target] } }

            {
              amount: target_amount,
              offices: offices
            }
          end

          get ':altcoin' do
            customer = Customer[params[:customer_id]]
            error!(404, 'Not found') unless customer

            office_id = params[:office_id]
            since_timepoint = params[:since] ? Time.parse( params[:since] ) : nil
            until_timepoint = params[:until] ? Time.parse( params[:until] ) : nil

            incomes = customer.transactions_dataset.incomes
            incomes = incomes.in_time_interval( since_timepoint, until_timepoint )
            incomes = incomes.where( source_currency_id: params[:altcoin] )

            source_amount, target_amount = incomes.amount_sums

            incomes = incomes.where( office_id: office_id ) if office_id
            offices = incomes
              .group(:office_id)
              .select_append { sum(target_amount).as(target) }
              .select_append { sum(source_amount).as(source) }
              .map do |o|
                { office_id: o.office_id, amount: o[:target], raw_amount: o[:source] }
              end

            {
              amount: target_amount,
              raw_amount: source_amount,
              offices: offices
            }
          end

        end

        params do
          optional :since
          optional :until
          optional :office_id
        end
        get 'txs' do
          since_timepoint = params[:since] ? Time.parse( params[:since] ) : nil
          until_timepoint = params[:until] ? Time.parse( params[:until] ) : nil

          payments = Payment.join(Wallet, :id => :wallet_id)
            .where( customer_id: params[:customer_id] )
            .select_all( :payments )
            .order( Sequel.desc(:payments__created_at) )
            .in_time_interval( since_timepoint, until_timepoint )

          payments = payments.where( office_id: params[:office_id] ) if params[:office_id]

          payments.map do |p|
            customer_amounts = p.customer_amounts

            {
              created_at: p.created_at.iso8601,
              incoming_currency_id: p.target_currency_id,
              incoming_amount: customer_amounts[0].to_f,
              confirmed: p.confirmed?,
              stored_amount: customer_amounts[1].to_f
            }
          end
        end

      end

      # change fee
    end

  end

end
end

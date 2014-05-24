module Coingate
module API

  class Customers < Grape::API

    helpers do
      def current_customer
        @current_customer ||= Customer[params[:customer_id]] || error!('Not found', 404)
      end

      def since_until_params
        since_timepoint = params[:since] ? Time.parse( params[:since] ) : nil
        until_timepoint = params[:until] ? Time.parse( params[:until] ) : nil

        [since_timepoint, until_timepoint]
      end
    end

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
              altcoin = params[:altcoin]
              office_id = params[:office_id]

              wallets = current_customer.wallets_dataset
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

              wallet = Coingate::Coin.for( altcoin ).create_wallet( customer, params[:office_id] )

              status 201
              { id: wallet.id, currency: wallet.incoming_currency_id, address: wallet.address }
            end

          end

        end

        get 'fee' do
          { fee: current_customer.current_fee_percent.to_f }
        end

        get 'balance' do
          { currency: current_customer.currency_id, amount: current_customer.balance.to_f }
        end

        params do
          optional :office_id
          optional :since
          optional :until
        end
        resource 'incomes' do
          get do
            office_id = params[:office_id]
            since_timepoint, until_timepoint = since_until_params

            incomes = current_customer.incomes_dataset
              .in_time_interval( since_timepoint, until_timepoint )

            source_amount, target_amount = incomes.amount_sums

            incomes = incomes.where( office_id: office_id ) if office_id

            default_incomes_per_office = current_customer.wallets_dataset
              .select(:id).distinct
              .map{|o| [o.id, 0] }

            incomes_per_office = incomes.amount_sums_by_office_id
              .map{|income| [income[:office_id], income[:target_amount_sum]] }


            incomes_array = Hash[default_incomes_per_office].merge( Hash[incomes_per_office] )
              .map{|k, v| { office_id: k, amount: v.to_f } }

            {
              amount: target_amount.to_f,
              offices: incomes_array
            }
          end

          get ':altcoin' do
            office_id = params[:office_id]

            since_timepoint, until_timepoint = since_until_params

            incomes = current_customer.incomes_dataset
              .in_time_interval( since_timepoint, until_timepoint )
              .where( source_currency_id: params[:altcoin] )

            source_amount, target_amount = incomes.amount_sums

            incomes = incomes.where( office_id: office_id ) if office_id

            default_incomes_per_office = current_customer.wallets_dataset
              .select(:id).distinct
              .map{|o| [o.id, [0, 0]] }

            incomes_per_office = incomes.amount_sums_by_office_id( include_source_amount_sum: true )
              .map{|income| [income[:office_id], [income[:target_amount_sum], income[:source_amount_sum]]] }

            incomes_array = Hash[default_incomes_per_office].merge( Hash[incomes_per_office] )
              .map{|k, v| { office_id: k, amount: v[0].to_f, raw_amount: v[1].to_f } }

            {
              amount: target_amount.to_f,
              raw_amount: source_amount.to_f,
              offices: incomes_array
            }
          end

        end

        params do
          optional :since
          optional :until
          optional :office_id
        end
        get 'txs' do
          customer_id = current_customer.id
          since_timepoint, until_timepoint = since_until_params

          payments = Payment.eager_graph( :wallet )
            .where( customer_id: customer_id )
            .order( Sequel.desc(:payments__created_at) )
            .in_time_interval( since_timepoint, until_timepoint )

          payments = payments.where( office_id: params[:office_id] ) if params[:office_id]

          payments.all.map do |p|
            source_amount, target_amount = p.customer_amounts

            {
              created_at: p.created_at.iso8601,
              source_currency_id: p.source_currency_id,
              source_amount: source_amount.to_f,
              confirmed: p.confirmed?,
              target_amount: target_amount.to_f
            }
          end
        end

      end

    end

  end

end
end

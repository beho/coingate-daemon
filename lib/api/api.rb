class API < Grape::API
  prefix '/api'
  version 'v1', :using => :path, :cascade => false
  format :json

  resources :rates do

    params do
      requires :source, type: String, desc: 'Source currency acronym.'
      requires :source, type: String, desc: 'Target currency acronym.'
      optional :at, type: DateTime, desc: 'Time for which to get rate; default is most recent rate.'
      optional :market, type: Integer, desc: 'Market ID; default is 1 – MtGox.'
    end
    get '/:source-:target' do
      timepoint = params[:at] || Time.now.utc
      market = params[:market] || 1

      rate = Rate.where{ at <= timepoint }
        .order( :at )
        .first(
          source_currency_id: params[:source],
          target_currency_id: params[:target],
          market_id: market )

      error!('Not Found', 404) unless rate

      rate.to_hash
    end

  end

end

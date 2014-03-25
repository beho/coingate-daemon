module Coingate

  class MtGox
    MARKET_ID = 1
    API_URL = 'https://mtgox.com/api/2/BTC%s/money/ticker'

    def btc_eur
      fetch_json( 'EUR' )
    end

    def fetch_json( currency )
      url = API_URL % [currency]
      response = RestClient.get( url )
      json = JSON.parse( response, symbolize_names: true )

      to_rate_hash( json, currency )
    end

    def to_rate_hash( response_json, target_currency )
      data = response_json[:data]

      {
        source_currency_id: 'BTC',
        target_currency_id: target_currency,
        market_id: MARKET_ID,
        at: Time.at( data[:now].to_i / 1e6 ).utc, # timestamp with resolution to microseconds
        high: data[:high][:value].to_f,
        low: data[:low][:value].to_f,
        avg: data[:avg][:value].to_f,
        buy: data[:buy][:value].to_f,
        sell: data[:sell][:value].to_f
      }
    end
  end

end

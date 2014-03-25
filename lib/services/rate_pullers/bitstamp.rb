module Coingate

  # https://www.bitstamp.net/api/
  class BitstampPuller
    MARKET_ID = 2
    API_URL = 'https://www.bitstamp.net/api/ticker/'

    def pull
      current = fetch_json

      {
        source_currency_id: 'BTC',
        target_currency_id: 'USD',
        market_id: 2,
        at: Time.at( current[:timestamp].to_i ).utc,
        buy: current[:bid].to_f,
        sell: current[:ask].to_f
      }
    end

    def fetch_json
      response = RestClient.get( API_URL )
      JSON.parse( response, symbolize_names: true )
    end
  end

end

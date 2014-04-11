module Coingate

  module API

    class Tx < Grape::API
      prefix '/api/tx'
      version 'v1', :using => :path, :cascade => true
      format :json

      params do
        requires :txid, type: String, desc: 'Tx id'
      end
      post 'btc' do
        channel = MQ_CONN.create_channel
        exchange = channel.direct('sneakers', durable: true )

        exchange.publish(params[:txid], routing_key: BTC_QUEUE)

        { :status => :accepted }
      end

      post 'xpm' do
        # channel = MQ_CONN.create_channel
        # exchange  = channel.default_exchange

        # msg = { txid: params[:txid] }.to_json

        # exchange.publish(msg, routing_key: 'txs.btc')

        # { :status => :accepted }
      end

    end

  end

end

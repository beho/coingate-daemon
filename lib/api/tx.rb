module Coingate

  module API

    class Tx < Grape::API
      prefix '/api/tx'
      version 'v1', :using => :path, :cascade => true
      format :json

      params do
        requires :txid, type: String, desc: 'Tx id'
      end
      post ':btc' do
        puts params[:txid]
      end

    end

  end

end

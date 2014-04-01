module Coingate

  module API

    class WebSupport < Grape::API
      prefix '/api/web'
      version 'v1', :using => :path, :cascade => true
      format :json

      mount Customers
      mount Rates
    end

  end

end

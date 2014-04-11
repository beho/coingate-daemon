module Coingate

  module API

    class Rates < Grape::API

      resources :rates do

        params do
          requires :source, type: String, desc: 'Source currency acronym.'
          requires :source, type: String, desc: 'Target currency acronym.'
          optional :at, type: DateTime, desc: 'Time for which to get rate; default is most recent rate.'
        end
        get '/:source/:target' do
          timepoint = params[:at] || Time.now.utc

          rate = Rate.for( params[:source].upcase, params[:target].upcase, timepoint )

          error!('Not Found', 404) unless rate

          { rate: rate.value }
        end

      end

    end

  end

end

set :output, "/coingate/coingated/shared/log/cron.log"
set :environment_variable, 'RACK_ENV'

# every 1.minutes do
#   rake 'cron:rates'
# end

every 1.minutes do
  rake 'cron:txs'
end

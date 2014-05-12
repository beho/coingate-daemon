set :output, "/coingate/coingate-daemon/shared/log/cron.log"

# every 1.minutes do
#   rake 'cron:rates'
# end

every 5.minutes do
  rake 'cron:txs'
end

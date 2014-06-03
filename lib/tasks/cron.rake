namespace :cron do

  desc 'Download rates from whatever markets'
  task :rates do
    Rate.multi_insert( Rate::Puller.new.pull_all )
  end

  desc 'Enqueue all all incoming transactions in case something went wrong with walletnotify'
  task :txs do
    Coingate::Coin.for(:btc).process_txs_since_last_checkpoint
  end

end

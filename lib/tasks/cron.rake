namespace :cron do

  desc 'Download rates from whatever markets'
  task :rates do
    Rate.multi_insert( Rate::Puller.new.pull_all )
  end

  desc 'Enqueue all incoming transactions in case something went wrong with walletnotify and reprocess pending transactions'
  task :txs do
    bitcoin = Coingate::Coin.for(:btc)

    bitcoin.process_txs_since_last_checkpoint
    bitcoin.reprocess_pending_txs
  end

end

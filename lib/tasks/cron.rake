namespace :cron do

  desc 'Download rates from whatever markets'
  task :rates do
    Rate.multi_insert( Rate::Puller.new.pull_all )
  end

  desc 'Enqueue all all incoming transactions in case something went wrong with walletnotify'
  task :txs do
    btc_interop = Coingate::Interop.btc
    btc = Coingate::Bitcoin.new

    checkpoint = TransactionCheckpoint['BTC']
    timestamp = checkpoint.timestamp

    page_size = 10
    offset = 0
    count = 0

    txs_data = btc_interop.listtransactions( "", page_size, offset ) # for default account

    if !txs_data.empty?
      latest = txs_data.map {|tx_data| tx_data['time'] }.max
    end

    done = false
    while !txs_data.empty? && !done
      txs_data.select {|tx_data| tx_data['category'] == 'receive' }.each do |tx_data|
        if timestamp.nil? || tx_data['time'] >= timestamp
          count += 1
          btc.get_tx_and_process( tx_data['txid'] )
        end
      end

      min_in_block = txs_data.map{|tx_data| tx_data['time'] }.min

      if !timestamp.nil? && min_in_block < timestamp
        done = true
        break
      end

      offset += page_size
      txs_data = btc_interop.listtransactions("", page_size, offset)
    end

    puts "[#{Time.now}] reprocessed #{count} BTC transactions received since checkpoint #{timestamp}"

    checkpoint.update( timestamp: latest ) if latest
  end

end

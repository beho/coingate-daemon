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

    count = 10
    offset = 0

    txs_data = btc_interop.listtransactions("", count, offset) # for default account

    if !txs_data.empty?
      latest = txs_data.map {|tx_data| tx_data['time'] }.max
    end

    done = false
    while !txs_data.empty? && !done
      txs_data.select {|tx_data| tx_data['category'] == 'receive' }.each do |tx_data|
        if checkpoint.timestamp.nil? || tx_data['time'] >= checkpoint.timestamp
          # puts "#{tx_data['time']} >= #{checkpoint.timestamp}"
          btc.get_tx_and_process( tx_data['txid'] )
        end
      end

      min_in_block = txs_data.map{|tx_data| tx_data['time'] }.min

      if !checkpoint.timestamp.nil? && min_in_block < checkpoint.timestamp
        done = true
        break
      end

      # puts "#{count} #{offset} #{txs_data.empty?}"
      offset += count
      txs_data = btc_interop.listtransactions("", count, offset)
    end

    checkpoint.update( timestamp: latest ) if latest
  end

end

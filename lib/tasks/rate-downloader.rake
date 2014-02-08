namespace :cron do

  desc 'Download rates from whatever markets'
  task :rates do
    Rate.multi_insert( Rate::Puller.new.pull_all )
  end

end

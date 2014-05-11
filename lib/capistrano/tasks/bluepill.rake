namespace :bluepill do
  desc "Restart processes that bluepill is monitoring"
  task :restart => ['bluepill:quit', 'bluepill:start']

  desc "Stop processes that bluepill is monitoring and quit bluepill"
  task :quit do
    on roles(:daemon) do
      # execute :sudo, "bluepill stop"
      # execute :sudo, "bluepill quit"
      execute "bluepill stop"
      execute "bluepill quit"
    end
  end

  desc "Load bluepill configuration and start it"
  task :start do
    on roles(:daemon) do
      # execute :sudo, "bluepill load /coingate/coingate-daemon/current/config/production.pill"
      execute "bluepill load /coingate/coingate-daemon/current/config/production.pill"
    end
  end

  desc "Prints bluepills monitored processes statuses"
  task :status do
    on roles(:daemon) do
      # execute :sudo, "bluepill status"
      execute "bluepill status"
    end
  end
end

namespace :bluepill do
  desc "Restart processes that bluepill is monitoring"
  task :restart => ['bluepill:quit', 'bluepill:start']

  desc "Stop processes that bluepill is monitoring and quit bluepill"
  task :quit do
    on roles(:daemon) do
      within release_path do
        # execute :sudo, "bluepill stop"
        # execute :sudo, "bluepill quit"
        execute :bluepill, "--no-privileged", :stop
        execute :bluepill, "--no-privileged", :quit
      end
    end
  end

  desc "Load bluepill configuration and start it"
  task :start do
    on roles(:daemon) do
      within release_path do
        # execute :sudo, "bluepill load /coingate/coingate-daemon/current/config/production.pill"
        execute :bluepill, "--no-privileged", :load, "/coingate/coingated/current/config/pills/production.pill"
      end
    end
  end

  desc "Prints bluepills monitored processes statuses"
  task :status do
    on roles(:daemon) do
      within release_path do
        # execute :sudo, "bluepill status"
        execute :bluepill, "--no-privileged", :status
      end
    end
  end
end

namespace :rabbitmq do
  namespace :mac do

    desc 'Starts installed RabbitMQ server.'
    task :start do
      puts 'Starting detached server...'
      result = %x[rabbitmq-server -detached]
      puts result
    end

    desc 'Stops installed RabbitMQ server.'
    task :stop do
      puts 'Stoping detached server...'
      result = %x[rabbitmqctl stop]
      puts result
    end

  end
end

Dir['./lib/models/*.rb'].each {|f| require f }
Dir['./lib/tasks/*.rb'].each {|f| require f }

autoload :API, './lib/api/api.rb'

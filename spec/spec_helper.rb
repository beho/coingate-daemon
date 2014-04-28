require 'simplecov'
SimpleCov.start do
  coverage_dir 'spec/coverage'
  add_group 'API', 'lib/api'
  add_group 'Models', 'lib/models'
  add_group 'Services', 'lib/services'
end

require_relative '../config/boot.rb'

RSpec.configure do |c|
  c.around(:each) do |example|
    Coingate.db.transaction(:rollback=>:always){example.run}
  end
end

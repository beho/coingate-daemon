require 'refinements'

Dir['./lib/models/**/*.rb'].each {|f| require f }

require_relative 'services/coind'
require_relative 'services/coinds/bitcoind'
require_relative 'services/interop'

Dir['./lib/workers/**/*.rb'].each {|f| require f }

require_relative 'api/customers'
require_relative 'api/rates'
require_relative 'api/web_support'

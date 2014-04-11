require 'refinements'

Dir['./lib/models/**/*.rb'].each {|f| require f }

require_relative 'services/coin'
require_relative 'services/coins/bitcoin'
require_relative 'services/interop'

Dir['./lib/workers/**/*.rb'].each {|f| require f }

require_relative 'api/customers'
require_relative 'api/rates'
require_relative 'api/tx'
require_relative 'api/web_support'

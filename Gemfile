source 'https://rubygems.org'

gem 'rake'
gem 'json', '~> 1.8.1'
gem 'rest-client', '~> 1.6.7'
gem 'sequel', '~> 4.7.0'
gem 'grape', '~> 0.6.1'
gem 'whenever', '~> 0.9.0', require: false
gem 'puma' # , '~> 2.7.1'

# version in rubygems can't listtransactions count, from
# https://github.com/stdyun/bitcoin-client/commit/2242ce05edb000d23e29c3c44c616e6166bbe122
gem 'bitcoin-client', :git => 'git://github.com/beho/bitcoin-client.git'

gem 'sneakers', '~> 0.1.1.pre' # frenzy_bunnies if JRuby
gem 'foreman', '~> 0.63.0'
gem 'bluepill', '~> 0.0.67'

gem 'pg', '~> 0.17.1'

group :development do
  # gem 'wirble'
  # gem 'pry-plus'

  gem 'capistrano', '~> 3.2.1'
  gem 'capistrano-bundler', '~> 1.1.2'

  gem 'rubocop', require: false

  gem 'rspec', '~> 3.0.0.beta2'
  gem 'simplecov', require: false
end

group :production do
end

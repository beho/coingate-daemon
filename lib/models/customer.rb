class Customer < Sequel::Model(:customers)
  unrestrict_primary_key
  plugin :timestamps
end

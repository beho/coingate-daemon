class Rate < Sequel::Model
  many_to_one :source_currency, class: :Currency
end

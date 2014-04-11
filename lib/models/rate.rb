class Rate < Sequel::Model
  many_to_one :source_currency, class: :Currency

  def self.for( source_currency_id, target_currency_id, timepoint = nil )
    (timepoint ? where{ at <= timepoint } : self)
      .order( :at )
      .first( source_currency_id: source_currency_id, target_currency_id: target_currency_id )
  end

  def self.current( source_currency_id, target_currency_id )
    self.for( source_currency_id, target_currency_id )
  end
end

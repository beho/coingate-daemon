class Payment < Sequel::Model( :payments )
  many_to_one :wallet
  one_to_one :transaction, :key => :transaction_id
  one_to_one :fee_transaction, :class => :Transaction, :key => :transaction_id
  plugin :timestamps

  SIGNIFICANT_DIGITS = 8

  def confirmed?
    !transaction.nil?
  end

  def split_source_amount
    self.class.split_amount( source_amount, rate, fee )
  end

  def split_target_amount
    self.class.split_amount( target_amount, rate, fee )
  end

  def self.split_amount( amount, rate, fee )
    real_amount = BigDecimal.new(amount, SIGNIFICANT_DIGITS) * BigDecimal.new(rate, SIGNIFICANT_DIGITS)
    fee = BigDecimal.new(fee, SIGNIFICANT_DIGITS)

    [real_amount * (1 - fee), real_amount * fee]
  end

  dataset_module do
    def in_time_interval( since_timepoint = nil, until_timepoint = nil )
      since( since_timepoint ).until( until_timepoint )
    end

    def since( since_timepoint = nil )
      since_timepoint ? where { transactions__created_at >= since_timepoint } : self
    end

    def until( until_timepoint = nil)
      until_timepoint ? where { transactions__created_at <= until_timepoint } : self
    end
  end
end

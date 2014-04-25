class Payment < Sequel::Model( :payments )
  many_to_one :wallet
  many_to_one :transaction # not really many_to_one
  many_to_one :fee_transaction, :class => :Transaction
  plugin :timestamps

  SIGNIFICANT_DIGITS = 8

  def confirmed?
    !transaction.nil?
  end

  def split_source_amount
    self.class.split_amount( source_amount, fee_percent )
  end

  def split_target_amount
    self.class.split_amount( target_amount, fee_percent )
  end

  def self.split_amount( amount, fee_percent )
    fee_percent = BigDecimal.new(fee_percent, SIGNIFICANT_DIGITS)

    [amount * (1 - fee_percent), amount * fee_percent]
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

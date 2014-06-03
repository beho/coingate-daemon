class Payment < Sequel::Model( :payments )
  many_to_one :wallet
  many_to_one :transaction # not really many_to_one
  many_to_one :fee_transaction, :class => :Transaction
  plugin :timestamps

  SIGNIFICANT_DIGITS = 8


  def self.split_amount( amount, fee_percent )
    fee_percent = BigDecimal.new(fee_percent, SIGNIFICANT_DIGITS)

    [amount * (1 - fee_percent), amount * fee_percent]
  end

  def confirmed?
    !confirmed_at.nil?
  end

  def confirm!
    customer = wallet.customer
    office_id = wallet.office_id
    system = Settings.system_customer

    source_income, source_fee = split_source_amount

    self.class.db.transaction( :isolation => :serializable, :retry_on => [Sequel::SerializationFailure] ) do
      return if refresh.confirmed?

      self.transaction = wallet.customer.create_transaction( source_currency_id, source_income, rate, office_id )
      self.fee_transaction = system.create_transaction( source_currency_id, source_fee, rate ) if fee_percent > 0
      self.status_id = PaymentStatus.id_for( :confirmed )
      self.confirmed_at = Time.now.utc

      save_changes

      Coingate.logger.info( "confirmed #{source_currency_id} payment[id: #{id}] for customer[id: #{customer.id}]. accounted with fee #{fee_percent.to_f * 100}% ")
    end
  end

  def invalidate!
    update( status_id: PaymentStatus.id_for( :invalid ) )
    # TODO reverse transactions
  end

  def customer_percent
    1 - fee_percent
  end

  def customer_amounts
    [source_amount * customer_percent, target_amount * customer_percent]
  end

  def split_source_amount
    self.class.split_amount( source_amount, fee_percent )
  end

  def split_target_amount
    self.class.split_amount( target_amount, fee_percent )
  end


  dataset_module do
    def in_time_interval( since_timepoint = nil, until_timepoint = nil )
      since( since_timepoint ).until( until_timepoint )
    end

    def since( since_timepoint = nil )
      since_timepoint ? where { payments__created_at >= since_timepoint } : self
    end

    def until( until_timepoint = nil)
      until_timepoint ? where { payments__created_at <= until_timepoint } : self
    end
  end
end

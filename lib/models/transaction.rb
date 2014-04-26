class Transaction < Sequel::Model( :transactions )
  plugin :timestamps

  dataset_module do
    def incomes
      where{ target_amount > 0 }
    end

    def amount_sums_by_office_id( customer_id )

    end

    def amount_sums
      sums = get { [sum(source_amount).as(source), sum(target_amount).as(target)] }

      [sums[0] || 0, sums[1] || 0]
    end

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

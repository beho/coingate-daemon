class Transaction < Sequel::Model( :transactions )
  plugin :timestamps

  dataset_module do
    def incomes
      where { target_amount > 0 }
    end

    def amount_sums
      sums = get { [sum(source_amount).as(source), sum(target_amount).as(target)] }

      [sums[0] || 0, sums[1] || 0]
    end

    # return hash with office_id, source_amount_sum, target_amount_sum
    # it is up to the caller to reasonably prepare a dataset to call this on
    # e.g. including source amount does not make sense when the dataset include multiple source currencies
    def amount_sums_by_office_id( include_target_amount_sum: true, include_source_amount_sum: false )
      dataset = self
        .group( :office_id )
        .select( :office_id )

      dataset = dataset.select_append { sum(target_amount).as(target_amount_sum) } if include_target_amount_sum
      dataset = dataset.select_append { sum(source_amount).as(source_amount_sum) } if include_source_amount_sum

      dataset.map do |o|
        office_hash = { office_id: o.office_id }
        office_hash[:target_amount_sum] = o[:target_amount_sum] if include_target_amount_sum
        office_hash[:source_amount_sum] = o[:source_amount_sum] if include_source_amount_sum

        office_hash
      end
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

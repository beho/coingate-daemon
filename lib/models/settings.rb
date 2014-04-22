class Settings < Sequel::Model( :settings )
  def self.instance
    self[1]
  end

  def self.fee_percent
    instance.fee_percent
  end

  def self.system_customer_id
    instance.system_customer_id
  end

  def self.system_customer
    Customer[self.system_customer_id]
  end

end

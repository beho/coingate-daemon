class Settings < Sequel::Model( :settings )
  def self.instance
    self[1]
  end

  def self.fee_percent
    instance.fee_percent
  end

end

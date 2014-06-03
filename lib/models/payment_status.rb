class PaymentStatus < Sequel::Model

	def self.id_for( symbol )
		case symbol
			when :pending then 0
			when :confirmed then 1
			when :invalid then 2
		end
	end
	
end

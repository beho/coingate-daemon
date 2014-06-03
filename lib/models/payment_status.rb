class PaymentStatus < Sequel::Model

	def self.id_for( symbol )
		case symbol
			when :pending then pending_id
			when :confirmed then confirmed_id
			when :invalid then invalid_id
		end
	end

	def self.pending_id
		0
	end

	def self.confirmed_id
		1
	end

	def self.invalid_id
		2
	end	
	
end

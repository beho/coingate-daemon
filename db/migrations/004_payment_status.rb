Sequel.migration do
	up do
		create_table(:payment_statuses) do
			primary_key :id
			String :description, size: 32
		end

		alter_table(:payments) do
			add_foreign_key :status_id, :payment_statuses
		end
	end

	down do
		alter_table(:payments) do
			drop_foreign_key :status_id
		end

		drop_table(:payment_statuses)
	end
end

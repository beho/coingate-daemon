Sequel.migration do
	up do
		rename_table(:transaction_checkpoints, :checkpoints)

		alter_table(:checkpoints) do
			drop_column :timestamp
			add_column :blockhash, String, size: 64
		end
	end

	down do
		rename_table(:checkpoints, :transaction_checkpoints)

		alter_table(:transaction_checkpoints) do
			drop_column :blockhash
			add_column :timestamp, Integer
		end
	end
end

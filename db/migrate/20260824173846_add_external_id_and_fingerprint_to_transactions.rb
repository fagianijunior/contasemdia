class AddExternalIdAndFingerprintToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :external_id, :string
    add_index :transactions, :external_id
    add_column :transactions, :fingerprint, :string
    add_index :transactions, :fingerprint
  end
end

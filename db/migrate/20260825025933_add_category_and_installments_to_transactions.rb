class AddCategoryAndInstallmentsToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :category, :string
    add_column :transactions, :installment, :integer
    add_column :transactions, :total_installments, :integer
  end
end

class AddBankToWallets < ActiveRecord::Migration[8.1]
  def change
    add_column :wallets, :bank, :string
  end
end

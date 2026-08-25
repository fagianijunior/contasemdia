class AddBankToCreditCards < ActiveRecord::Migration[8.1]
  def change
    add_column :credit_cards, :bank, :string
  end
end

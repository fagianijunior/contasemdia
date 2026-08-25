class UpdateTransactionsForeignKeyToCascade < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :transactions, :wallets
    remove_foreign_key :transactions, :credit_cards

    add_foreign_key :transactions, :wallets, on_delete: :cascade
    add_foreign_key :transactions, :credit_cards, on_delete: :cascade
  end
end

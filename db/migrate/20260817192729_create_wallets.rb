class CreateWallets < ActiveRecord::Migration[8.1]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :wallet_type
      t.decimal :balance, precision: 10, scale: 2

      t.timestamps
    end
  end
end

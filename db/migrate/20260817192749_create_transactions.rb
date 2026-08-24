class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :wallet, null: false, foreign_key: true
      t.references :credit_card, null: false, foreign_key: true
      t.string :title
      t.decimal :amount, precision: 10, scale: 2
      t.integer :transaction_type
      t.integer :status
      t.date :due_date
      t.date :payment_date

      t.timestamps
    end
  end
end

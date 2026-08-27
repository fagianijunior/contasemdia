class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      
      # Corrigido: on_delete vai dentro do hash foreign_key
      t.references :wallet, null: true, foreign_key: { on_delete: :cascade }
      t.references :credit_card, null: true, foreign_key: { on_delete: :cascade }
      
      t.string :title
      t.decimal :amount, precision: 10, scale: 2
      t.integer :transaction_type
      t.integer :status
      t.date :due_date
      t.date :payment_date
      t.string :external_id
      t.string :fingerprint
      t.integer :installment
      t.integer :total_installments
      t.reference :category, foreign_key: true, null: true
      t.string :tags, array: true, default: []
      
      t.timestamps
    end
    add_index :transactions, :external_id
    add_index :transactions, :fingerprint
    add_index :transactions, :category_id
  end
end
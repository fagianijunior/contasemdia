class CreateCreditCards < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.decimal :limit, precision: 10, scale: 2
      t.integer :closing_day
      t.integer :due_day
      t.references :bank, null: true, foreign_key: true

      t.timestamps
    end
  end
end

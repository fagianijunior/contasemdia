class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :user, foreign_key: true, null: true 
      t.string :name, null: false
      t.string :icon
      t.integer :category_type, default: 0, null: false

      t.timestamps
    end
    add_index :categories, [:user_id, :category_type]
  end
end

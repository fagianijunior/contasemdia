class CreateBanks < ActiveRecord::Migration[8.1]
  def change
    create_table :banks do |t|
      t.string :name
      t.string :code
      t.string :color
      t.string :logo_url

      t.timestamps
    end
  end
end

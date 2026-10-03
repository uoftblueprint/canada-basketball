class CreateCamps < ActiveRecord::Migration[8.1]
  def change
    create_table :camps do |t|
      t.string :name, null: false
      t.string :password_digest

      t.timestamps
    end
    add_index :camps, :name, unique: true
  end
end

class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.references :camp, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :opponent_name, null: false

      t.timestamps
    end

    add_index :games, [:camp_id, :name], unique: true
  end
end

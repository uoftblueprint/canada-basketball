class CreateCampRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :camp_registrations do |t|
      t.references :camp, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.references :team, null: true, foreign_key: true

      t.timestamps
    end
    add_index :camp_registrations, [:camp_id, :player_id], unique: true
  end
end

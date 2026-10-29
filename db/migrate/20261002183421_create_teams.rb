class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.references :camp, null: false, foreign_key: true

      t.timestamps
    end

    add_index :teams, [:camp_id, :name], unique: true
  end
end

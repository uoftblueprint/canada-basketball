class CreateCampAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :camp_assignments do |t|
      t.references :team, null: false, foreign_key: true
      t.references :camp, null: false, foreign_key: true

      t.timestamps
    end
    add_index :camp_assignments, [:team_id, :camp_id], unique: true
  end
end

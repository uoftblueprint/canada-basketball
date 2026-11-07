class CreateGameStatLines < ActiveRecord::Migration[8.1]
  def change
    create_table :game_stat_lines do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: true, foreign_key: true
      t.boolean :is_opponent, null: false, default: false

      t.integer :two_pm, null: false, default: 0
      t.integer :two_pa, null: false, default: 0
      t.integer :three_pm, null: false, default: 0
      t.integer :three_pa, null: false, default: 0
      t.integer :ftm, null: false, default: 0
      t.integer :fta, null: false, default: 0
      t.integer :fgm, null: false, default: 0
      t.integer :fga, null: false, default: 0
      t.integer :pts, null: false, default: 0
      t.integer :orb, null: false, default: 0
      t.integer :drb, null: false, default: 0
      t.integer :trb, null: false, default: 0
      t.integer :ast, null: false, default: 0
      t.integer :tov, null: false, default: 0
      t.integer :pf, null: false, default: 0
      t.integer :stl, null: false, default: 0
      t.integer :blk, null: false, default: 0

      t.timestamps
    end

    add_index :game_stat_lines, [:game_id, :player_id], unique: true, where: "player_id IS NOT NULL"
    add_index :game_stat_lines, [:game_id, :is_opponent], unique: true, where: "player_id IS NULL"

    add_check_constraint :game_stat_lines, "NOT (is_opponent AND player_id IS NOT NULL)", name: "opponent_stat_lines_have_no_player"
  end
end

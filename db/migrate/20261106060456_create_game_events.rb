class CreateGameEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :game_events do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: true, foreign_key: true
      t.boolean :is_opponent, null: false, default: false
      t.string :kind, null: false
      t.string :period, null: false, default: "Q1"
      t.timestamps
    end

    add_index :game_events, %i[game_id is_opponent player_id]
    add_index :game_events, %i[game_id created_at id]

    add_check_constraint :game_events, "NOT (is_opponent AND player_id IS NOT NULL)",
                         name: "opponent_events_have_no_player"
  end
end

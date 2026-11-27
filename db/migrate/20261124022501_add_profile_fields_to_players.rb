class AddProfileFieldsToPlayers < ActiveRecord::Migration[8.1]
  def change
    add_column :players, :birth_year, :integer
    add_column :players, :height_cm, :integer
    add_column :players, :province, :string
    add_column :players, :hometown, :string

    add_check_constraint :players,
      "birth_year BETWEEN 1900 AND 2100",
      name: "players_birth_year_range"

    add_check_constraint :players,
      "height_cm > 50 AND height_cm < 300",
      name: "players_height_cm_range"

    add_check_constraint :players,
      "province IN ('AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT')",
      name: "players_province_valid"
  end
end
require "test_helper"

class GameStatLineTest < ActiveSupport::TestCase
  test "percentage columns are zero when there are no attempts" do
    line = GameStatLine.create!(game: create(:game))
    line.reload

    assert_in_delta 0.0, line.fg_pct
    assert_in_delta 0.0, line.two_p_pct
    assert_in_delta 0.0, line.three_p_pct
    assert_in_delta 0.0, line.ft_pct
  end

  test "percentage columns divide makes over attempts" do
    line = GameStatLine.create!(
      game: create(:game),
      fgm: 3, fga: 6,
      two_pm: 1, two_pa: 2,
      three_pm: 2, three_pa: 4,
      ftm: 1, fta: 4
    )
    line.reload

    assert_in_delta 0.5, line.fg_pct
    assert_in_delta 0.5, line.two_p_pct
    assert_in_delta 0.5, line.three_p_pct
    assert_in_delta 0.25, line.ft_pct
  end

  test "percentage columns are sortable through the index table" do
    GameStatLine::PERCENTAGE_COLUMNS.each do |column|
      assert_includes GameStatLine.sortable_columns, column.to_s
    end
  end

  test "COLUMNS match the writable stat columns on the table" do
    metadata = %w[id game_id player_id is_opponent created_at updated_at]
    generated = GameStatLine.columns.select { |c| c.respond_to?(:virtual?) && c.virtual? }.map(&:name)

    assert_equal GameStatLine::COLUMNS.map(&:to_s).sort,
                 (GameStatLine.column_names - metadata - generated).sort
  end
end

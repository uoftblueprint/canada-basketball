require "test_helper"

class GameStatLineTest < ActiveSupport::TestCase
  test "percentages are zero when there are no attempts" do
    line = GameStatLine.new

    assert_equal 0.0, line.fg_pct
    assert_equal 0.0, line.two_p_pct
    assert_equal 0.0, line.three_p_pct
    assert_equal 0.0, line.ft_pct
  end

  test "percentages divide makes over attempts" do
    line = GameStatLine.new(
      fgm: 3, fga: 6,
      two_pm: 1, two_pa: 2,
      three_pm: 2, three_pa: 4,
      ftm: 1, fta: 4
    )

    assert_in_delta 0.5, line.fg_pct
    assert_in_delta 0.5, line.two_p_pct
    assert_in_delta 0.5, line.three_p_pct
    assert_in_delta 0.25, line.ft_pct
  end

  test "match the stat columns on the table" do
    metadata = %w[id game_id player_id is_opponent created_at updated_at]

    assert_equal GameStatLine::COLUMNS.map(&:to_s).sort,
                 (GameStatLine.column_names - metadata).sort
  end
end

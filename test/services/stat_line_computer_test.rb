require "test_helper"

class StatLineComputerTest < ActiveSupport::TestCase
  def setup
    @game = create(:game)
    @player = register_player(@game)
  end

  test "each event kind produces the correct stat deltas" do
    GameEvent::STAT_DELTAS.each do |kind, deltas|
      game = create(:game)
      player = register_player(game)
      create(:game_event, game: game, player: player, kind: kind)

      line = GameStatLine.find_by!(game: game, player: player, is_opponent: false)

      deltas.each do |column, amount|
        assert_equal amount, line.public_send(column), "#{kind} should set #{column}"
      end

      untouched = GameStatLine::BASE_COLUMNS - deltas.keys
      untouched.each do |column|
        assert_equal 0, line.public_send(column), "#{kind} should leave #{column} at 0"
      end
    end
  end

  test "derived columns are computed from the base counts" do
    create(:game_event, game: @game, player: @player, kind: :three_point_made)
    create(:game_event, game: @game, player: @player, kind: :two_point_made)
    create(:game_event, game: @game, player: @player, kind: :free_throw_made)
    create(:game_event, game: @game, player: @player, kind: :offensive_rebound)
    create(:game_event, game: @game, player: @player, kind: :defensive_rebound)

    line = stat_line_for(@player)

    assert_equal 2, line.fgm
    assert_equal 2, line.fga
    assert_equal 2, line.trb
    assert_equal 6, line.pts
  end

  test "repeated events of the same kind accumulate" do
    create_list(:game_event, 3, game: @game, player: @player, kind: :three_point_made)

    line = stat_line_for(@player)

    assert_equal 3, line.three_pm
    assert_equal 3, line.three_pa
    assert_equal 9, line.pts
  end

  test "removing the last event for a stat line deletes the stat line" do
    event = create(:game_event, game: @game, player: @player, kind: :assist)
    assert stat_line_for(@player)

    event.destroy!

    assert_nil GameStatLine.find_by(game: @game, player: @player, is_opponent: false)
  end

  test "opponent events amalgamate into a single line" do
    create(:game_event, :opponent, game: @game, kind: :three_point_made)
    create(:game_event, :opponent, game: @game, kind: :two_point_made)

    lines = GameStatLine.where(game: @game, is_opponent: true)

    assert_equal 1, lines.count
    assert_equal 5, lines.sole.pts
  end

  test "team events form an own-team unattributed line" do
    create(:game_event, :team, game: @game, kind: :defensive_rebound)

    line = GameStatLine.find_by!(game: @game, player: nil, is_opponent: false)

    assert_equal 1, line.drb
    assert_equal 1, line.trb
  end

  private

  def register_player(game)
    create(:player).tap do |player|
      create(:camp_registration, camp: game.camp, player: player, team: game.team)
    end
  end

  def stat_line_for(player)
    GameStatLine.find_by(game: @game, player: player, is_opponent: false)
  end
end

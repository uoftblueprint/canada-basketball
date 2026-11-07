require "test_helper"

class GameEventTest < ActiveSupport::TestCase
  def setup
    @game = create(:game)
    @player = register_player(@game)
  end

  test "is valid for a player registered on the game's team" do
    assert build(:game_event, game: @game, player: @player).valid?
  end

  test "opponent event must not have a player" do
    event = build(:game_event, game: @game, player: @player, is_opponent: true)

    assert_not event.valid?
    assert_includes event.errors[:player], "must be blank for opponent events"
  end

  test "non-opponent player must be on the game's team" do
    other_player = create(:player)
    event = build(:game_event, game: @game, player: other_player, is_opponent: false)

    assert_not event.valid?
    assert_includes event.errors[:player], "must be on the game's team"
  end

  test "team event with no player is valid" do
    assert build(:game_event, :team, game: @game).valid?
  end

  test "creating an event builds a stat line for its key" do
    create(:game_event, game: @game, player: @player, kind: :two_point_made)

    lines = GameStatLine.where(game: @game, player: @player, is_opponent: false)

    assert_equal 1, lines.count
    assert_equal 2, lines.sole.pts
  end

  test "reassigning an event's player recomputes the old and new lines" do
    event = create(:game_event, game: @game, player: @player, kind: :three_point_made)
    other_player = register_player(@game)

    event.update!(player: other_player)

    assert_nil GameStatLine.find_by(game: @game, player: @player, is_opponent: false),
               "old line should be removed once it has no events"
    assert_equal 3, GameStatLine.find_by!(game: @game, player: other_player, is_opponent: false).pts
  end

  test "switching an event to the opponent moves its stats to the opponent line" do
    event = create(:game_event, game: @game, player: @player, kind: :two_point_made)

    event.update!(player: nil, is_opponent: true)

    assert_nil GameStatLine.find_by(game: @game, player: @player, is_opponent: false)
    assert_equal 2, GameStatLine.find_by!(game: @game, player: nil, is_opponent: true).pts
  end

  private

  def register_player(game)
    create(:player).tap do |player|
      create(:camp_registration, camp: game.camp, player: player, team: game.team)
    end
  end
end

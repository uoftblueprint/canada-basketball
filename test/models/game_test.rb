require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @game = create(:game)
  end

  test "should not allow teams not in the camp to be assigned to it" do
    new_team = create(:team)
    @game.team = new_team

    assert_raises(ActiveRecord::RecordInvalid) do
      @game.save!
    end
  end

  test "should not allow duplicate game name within the same camp" do
    duplicate = build(:game, name: @game.name, camp: @game.camp)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "team_totals computes percentages from summed counts, not averaged ratios" do
    sharp = register_player
    cold = register_player
    create(:game_event, game: @game, player: sharp, kind: :two_point_made)
    create_list(:game_event, 3, game: @game, player: cold, kind: :two_point_missed)

    # ratio of sums = 1/4 = 0.25; averaging the two players' ratios would give 0.5
    assert_in_delta 0.25, @game.team_totals.fg_pct
  end

  test "team_totals sums your-team rows and excludes the opponent" do
    player = register_player
    create(:game_event, game: @game, player: player, kind: :three_point_made)
    create(:game_event, game: @game, player: nil, is_opponent: false, kind: :turnover)
    create(:game_event, game: @game, player: nil, is_opponent: true, kind: :two_point_made)

    assert_equal 3, @game.team_totals.pts
    assert_equal 1, @game.team_totals.tov
  end

  test "team_totals is zero (not nil) for a game with no events" do
    assert_equal 0, @game.team_totals.pts
    assert_nil @game.team_totals.fg_pct
  end

  private

  def register_player
    create(:player).tap do |player|
      create(:camp_registration, camp: @game.camp, player: player, team: @game.team)
    end
  end
end

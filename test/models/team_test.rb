require "test_helper"

class TeamTest < ActiveSupport::TestCase
  test "can have many camps associated with it" do
    team = create(:team)

    camp1 = create(:camp)
    camp2 = create(:camp)

    team.camps << camp1
    team.camps << camp2

    assert_equal 2, team.camps.count
  end

  test "should nullify players when it is destroyed" do
    team_with_players = create(:team, :with_players)

    players = team_with_players.players.to_a
    team_with_players.destroy!

    assert(players.all? { |player| player.reload.team.nil? })
  end

  test "should prevent destruction when there are games associated with it" do
    team_with_games = create(:team, :with_games)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      team_with_games.destroy!
    end
  end
end

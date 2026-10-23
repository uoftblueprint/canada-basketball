require "test_helper"

class TeamTest < ActiveSupport::TestCase
  test "is invalid without a camp" do
    team = build(:team, camp: nil)

    assert_not team.valid?
    assert_includes team.errors[:camp], "must exist"
  end

  test "rejects a duplicate name within the same camp" do
    team = create(:team, name: "Raptors")
    duplicate = build(:team, name: "Raptors", camp: team.camp)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "allows the same name in a different camp" do
    create(:team, name: "Raptors")

    assert build(:team, name: "Raptors", camp: create(:camp)).valid?
  end

  test "should nullify registrations when it is destroyed, keeping players in the camp" do
    team_with_players = create(:team, :with_players)

    registrations = team_with_players.camp_registrations.to_a
    team_with_players.destroy!

    assert(registrations.all? { |r| r.reload.team_id.nil? })
    assert(registrations.all? { |r| r.camp.players.include?(r.player) })
  end

  test "should prevent destruction when there are games associated with it" do
    team_with_games = create(:team, :with_games)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      team_with_games.destroy!
    end
  end
end

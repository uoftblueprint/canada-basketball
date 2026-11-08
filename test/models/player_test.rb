require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "requires a name" do
    player = build(:player, name: nil)

    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end

  test "cannot be destroyed while it has game events" do
    game = create(:game)
    player = create(:player)
    create(:camp_registration, camp: game.camp, player: player, team: game.team)
    create(:game_event, game: game, player: player, kind: :two_point_made)

    assert_not player.destroy
    assert_includes player.errors[:base], "Cannot delete record because dependent game events exist"
  end
end

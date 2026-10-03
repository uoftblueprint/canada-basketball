require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "is valid without a team" do
    player = build(:player, team: nil)

    assert player.valid?
  end

  test "requires a name" do
    player = build(:player, name: nil)

    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end
end

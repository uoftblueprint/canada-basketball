require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "requires a name" do
    player = build(:player, name: nil)

    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end
end

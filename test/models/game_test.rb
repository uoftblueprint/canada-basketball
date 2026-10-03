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
end

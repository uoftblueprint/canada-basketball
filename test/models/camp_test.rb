require "test_helper"

class CampTest < ActiveSupport::TestCase
  test "can have many teams associated with it" do
    camp = create(:camp)
    team1 = create(:team)
    team2 = create(:team)

    camp.teams << team1
    camp.teams << team2

    assert_equal 2, camp.teams.count
  end

  test "should prevent destruction when there are games associated with it" do
    camp = create(:camp, :with_games)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      camp.destroy!
    end
  end
end

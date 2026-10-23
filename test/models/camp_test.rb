require "test_helper"

class CampTest < ActiveSupport::TestCase
  test "can have many teams associated with it" do
    camp = create(:camp)
    create(:team, camp: camp)
    create(:team, camp: camp)

    assert_equal 2, camp.teams.count
  end

  test "should prevent destruction when there are games associated with it" do
    camp = create(:camp, :with_games)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      camp.destroy!
    end
  end
end

require "test_helper"

class CampRegistrationTest < ActiveSupport::TestCase
  test "rejects duplicate player in the same camp" do
    camp_registration = create(:camp_registration)
    duplicate = build(:camp_registration, camp: camp_registration.camp, player: camp_registration.player)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:player_id], "has already been taken"
  end

  test "rejects a team from a different camp" do
    camp_registration = build(:camp_registration, team: create(:team))
    assert_not camp_registration.valid?
  end

  test "is valid with no team" do
    camp_registration = create(:camp_registration, team: nil)
    assert camp_registration.valid?
  end
end

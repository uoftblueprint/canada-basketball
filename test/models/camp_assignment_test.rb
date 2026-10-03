require "test_helper"

class CampAssignmentTest < ActiveSupport::TestCase
  def setup
    @camp_assignment = create(:camp_assignment)
  end

  test "should not allow duplicate camp assignment for a team" do
    duplicate = build(:camp_assignment, camp: @camp_assignment.camp, team: @camp_assignment.team)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:team_id], "has already been taken"
  end
end

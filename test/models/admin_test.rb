require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "should validate email uniqueness case-insensitively" do
    create(:admin, email: "admin@test.com")
    duplicate = build(:admin, email: "ADMIN@TEST.COM")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end
end

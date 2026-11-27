require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "available roles are manager and analyst" do
    assert_equal %w[manager analyst], Admin.roles.keys
  end

  test "role defaults to manager" do
    admin = Admin.new

    assert_equal "manager", admin.role
    assert_predicate admin, :manager?
    assert_not_predicate admin, :analyst?
  end

  %i[manager analyst].each do |role|
    test "#{role} role is valid and persists" do
      admin = create(:admin, role)

      assert_predicate admin.reload, :valid?
      assert_equal role.to_s, admin.role
      assert_predicate admin, :"#{role}?"
      (Admin.roles.keys - [role.to_s]).each do |other_role|
        assert_not_predicate admin, :"#{other_role}?"
      end
    end
  end

  test "role can be changed from manager to analyst" do
    admin = create(:admin, :manager)

    admin.update!(role: :analyst)

    assert_predicate admin.reload, :analyst?
    assert_not_predicate admin, :manager?
  end

  test "role rejects missing and unsupported values" do
    [nil, "", "admin", "unsupported"].each do |role|
      admin = build(:admin, role: role)

      assert_not admin.valid?
      assert_includes admin.errors[:role], "is not included in the list"
    end
  end

  test "should validate email uniqueness case-insensitively" do
    create(:admin, email: "admin@test.com")
    duplicate = build(:admin, email: "ADMIN@TEST.COM")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end
end

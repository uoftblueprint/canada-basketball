require "test_helper"

class AdminsControllerTest < ActionDispatch::IntegrationTest
  test "index is accessible by admins" do
    create_logged_in_admin

    get admins_path

    assert_response :success
  end

  test "index lists admin names and emails" do
    create_logged_in_admin
    create(:admin, name: "Jane Doe", email: "jane@test.com")

    get admins_path

    assert_select "td", text: "Jane Doe"
    assert_select "td", text: "jane@test.com"
  end

  test "index redirects camp users" do
    create_logged_in_camp

    get admins_path

    assert_redirected_to login_path
    assert_equal "You must be logged in as an admin to access this page", flash[:error]
  end

  test "index redirects logged out users" do
    get admins_path

    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:error]
  end
end

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

  test "new is accessible by admins" do
    create_logged_in_admin

    get new_admin_path

    assert_response :success
  end

  test "create makes a new admin" do
    create_logged_in_admin

    assert_difference("Admin.count", 1) do
      post admins_path, params: {
        admin: { name: "Jane Doe", email: "jane@test.com", password: "password", password_confirmation: "password" }
      }
    end

    assert_redirected_to root_path
    assert_equal "Admin created.", flash[:success]
    assert Admin.exists?(email: "jane@test.com")
  end

  test "create re-renders new with invalid params" do
    create_logged_in_admin

    assert_no_difference("Admin.count") do
      post admins_path, params: {
        admin: { name: "", email: "", password: "password", password_confirmation: "password" }
      }
    end

    assert_response :unprocessable_content
  end

  [
    { who: "camp users", logged_in: :create_logged_in_camp,
      message: "You must be logged in as an admin to access this page" },
    { who: "logged out users", logged_in: nil,
      message: "You must be logged in to access this page" }
  ].each do |user|
    test "new redirects #{user[:who]}" do
      send(user[:logged_in]) if user[:logged_in]

      get new_admin_path

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "create redirects #{user[:who]}" do
      send(user[:logged_in]) if user[:logged_in]

      assert_no_difference("Admin.count") do
        post admins_path, params: {
          admin: { name: "Sneaky", email: "sneaky@test.com", password: "password", password_confirmation: "password" }
        }
      end

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end
  end

  test "destroy deletes the admin" do
    create_logged_in_admin
    admin = create(:admin)

    assert_difference("Admin.count", -1) { delete admin_path(admin) }

    assert_redirected_to admins_path
    assert_equal "Admin deleted successfully", flash[:success]
  end

  test "destroy redirects camp users" do
    create_logged_in_camp
    admin = create(:admin)

    assert_no_difference("Admin.count") { delete admin_path(admin) }

    assert_redirected_to login_path
  end

  test "destroy redirects logged out users" do
    admin = create(:admin)

    assert_no_difference("Admin.count") { delete admin_path(admin) }

    assert_redirected_to login_path
  end
end

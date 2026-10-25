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

    assert_redirected_to admins_path
    assert_equal I18n.t("admins.create.success"), flash[:success]
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

  test "admin can access the edit admin page" do
    create_logged_in_admin
    admin = create(:admin)

    get edit_admin_path(admin)

    assert_response :success
  end

  test "edit admin page is prefilled with the admin's email and name" do
    create_logged_in_admin
    admin = create(:admin, name: "Jane Doe", email: "jane@test.com")

    get edit_admin_path(admin)

    assert_select "input[name='admin[email]'][value=?]", "jane@test.com"
    assert_select "input[name='admin[name]'][value=?]", "Jane Doe"
    assert_select "input[name='admin[password]']"
    assert_select "input[name='admin[password_confirmation]']"
  end

  test "edit returns not found for a nonexistent admin" do
    create_logged_in_admin

    get edit_admin_path(0)

    assert_response :not_found
  end

  test "admin can update an admin's email, name, and password" do
    create_logged_in_admin
    admin = create(:admin)

    patch admin_path(admin), params: {
      admin: { email: "new@test.com", name: "New Name", password: "newpassword", password_confirmation: "newpassword" }
    }

    assert_redirected_to admins_path
    assert_equal I18n.t("admins.update.success"), flash[:success]
    admin.reload
    assert_equal "new@test.com", admin.email
    assert_equal "New Name", admin.name
    assert admin.authenticate("newpassword")
  end

  test "leaving password blank keeps the current password" do
    create_logged_in_admin
    admin = create(:admin, password: "password")

    patch admin_path(admin), params: {
      admin: { email: admin.email, name: "Renamed", password: "", password_confirmation: "" }
    }

    assert_redirected_to admins_path
    admin.reload
    assert_equal "Renamed", admin.name
    assert admin.authenticate("password")
  end

  test "update fails when password confirmation does not match" do
    create_logged_in_admin
    admin = create(:admin, password: "password")

    patch admin_path(admin), params: {
      admin: { email: admin.email, name: admin.name, password: "newpassword", password_confirmation: "different" }
    }

    assert_response :unprocessable_content
    assert admin.reload.authenticate("password")
  end

  test "update fails with an invalid email" do
    create_logged_in_admin
    admin = create(:admin, email: "old@test.com")

    patch admin_path(admin), params: { admin: { email: "not-an-email", name: admin.name } }

    assert_response :unprocessable_content
    assert_equal "old@test.com", admin.reload.email
  end

  test "update fails with a blank name" do
    create_logged_in_admin
    admin = create(:admin, name: "Old Name")

    patch admin_path(admin), params: { admin: { email: admin.email, name: "" } }

    assert_response :unprocessable_content
    assert_equal "Old Name", admin.reload.name
  end

  test "update fails with an email already taken by another admin" do
    create_logged_in_admin
    create(:admin, email: "taken@test.com")
    admin = create(:admin, email: "mine@test.com")

    patch admin_path(admin), params: { admin: { email: "TAKEN@test.com", name: admin.name } }

    assert_response :unprocessable_content
    assert_equal "mine@test.com", admin.reload.email
  end

  [
    { who: "A camp", logged_in_as_camp: true, message: "You must be logged in as an admin to access this page" },
    { who: "A logged out user", logged_in_as_camp: false, message: "You must be logged in to access this page" }
  ].each do |user|
    test "#{user[:who]} cannot access the new admin page" do
      create_logged_in_camp if user[:logged_in_as_camp]

      get new_admin_path

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "#{user[:who]} cannot access the edit admin page" do
      create_logged_in_camp if user[:logged_in_as_camp]
      admin = create(:admin)

      get edit_admin_path(admin)

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "#{user[:who]} cannot create an admin" do
      create_logged_in_camp if user[:logged_in_as_camp]

      assert_no_difference("Admin.count") do
        post admins_path, params: {
          admin: { name: "Sneaky", email: "sneaky@test.com", password: "password", password_confirmation: "password" }
        }
      end

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "#{user[:who]} cannot update an admin" do
      create_logged_in_camp if user[:logged_in_as_camp]
      admin = create(:admin, name: "Old Name")

      patch admin_path(admin), params: { admin: { name: "Hacked" } }

      assert_redirected_to login_path
      assert_equal "Old Name", admin.reload.name
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

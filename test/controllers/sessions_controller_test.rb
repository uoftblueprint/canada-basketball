require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = create(:admin, email: "admin@test.com", password: "password")
    @camp = create(:camp, password: "password")
  end

  test "Create admin redirects to root path when login is successful and sets admin_id in session" do
    post login_admin_path, params: { email: "admin@test.com", password: "password" }

    assert_redirected_to root_path
    assert_equal "Logged in as admin successfully", flash[:success]
    assert_equal @admin.id, session[:admin_id]
  end

  test "Create redirects to root path when login is successful and sets camp_id in session" do
    post login_path, params: { camp_id: @camp.id, password: "password" }

    assert_redirected_to root_path
    assert_equal "Logged in successfully", flash[:success]
    assert_equal @camp.id, session[:camp_id]
  end

  test "Create admin does not allow login with the wrong password" do
    post login_admin_path, params: { email: "admin@test.com", password: "wrongpassword" }

    assert_redirected_to login_admin_path
    assert_equal "Invalid email or password", flash[:error]
    assert_nil session[:admin_id]
  end

  test "Create does not allow login with the wrong password" do
    post login_path, params: { camp_id: @camp.id, password: "wrongpassword" }

    assert_redirected_to login_path
    assert_equal "Invalid camp or password", flash[:error]
    assert_nil session[:camp_id]
  end

  test "Logout clears admin from session" do
    post login_admin_path, params: { email: "admin@test.com", password: "password" }
    delete logout_path

    assert_redirected_to root_path
    assert_equal "Logged out successfully", flash[:success]
    assert_nil session[:admin_id]
  end

  test "Logout clears camp from session" do
    post login_path, params: { camp_id: @camp.id, password: "password" }
    delete logout_path

    assert_redirected_to root_path
    assert_equal "Logged out successfully", flash[:success]
    assert_nil session[:camp_id]
  end
end

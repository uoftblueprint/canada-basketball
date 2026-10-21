require "test_helper"

class CampsControllerTest < ActionDispatch::IntegrationTest
  test "index is accessible by admins" do
    create_logged_in_admin

    get camps_path

    assert_response :success
  end

  test "index lists camps with active camps first, then by name" do
    create_logged_in_admin
    create(:camp, :inactive, name: "A Camp")
    create(:camp, name: "C Camp")
    create(:camp, name: "B Camp", description: "B description")

    get camps_path

    assert_equal ["B Camp", "C Camp", "A Camp"], css_select("tbody tr td:first-child").map(&:text)
    assert_select "tbody tr:first-child td", text: "B description"
    assert_select "tbody tr:last-child td", text: "Inactive"
  end

  test "index redirects camp users" do
    create_logged_in_camp

    get camps_path

    assert_redirected_to login_path
    assert_equal "You must be logged in as an admin to access this page", flash[:error]
  end

  test "index redirects logged out users" do
    get camps_path

    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:error]
  end

  test "destroy deletes the camp" do
    create_logged_in_admin
    camp = create(:camp)

    assert_difference("Camp.count", -1) { delete camp_path(camp) }

    assert_redirected_to camps_path
    assert_equal "Camp deleted successfully", flash[:success]
  end

  test "destroy does not delete a camp with games" do
    create_logged_in_admin
    camp = create(:camp, :with_games)

    assert_no_difference("Camp.count") { delete camp_path(camp) }

    assert_redirected_to camps_path
    assert_equal "Cannot delete record because dependent games exist", flash[:error]
  end

  test "destroy redirects camp users" do
    camp = create_logged_in_camp

    assert_no_difference("Camp.count") { delete camp_path(camp) }

    assert_redirected_to login_path
  end

  test "destroy redirects logged out users" do
    camp = create(:camp)

    assert_no_difference("Camp.count") { delete camp_path(camp) }

    assert_redirected_to login_path
  end
end

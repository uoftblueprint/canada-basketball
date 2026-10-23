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
  def setup
    @camp_attributes = attributes_for(:camp, active: false)
  end

  test "admin can create a camp without exposing its password digest" do
    create_logged_in_admin

    assert_difference("Camp.count", 1) do
      post "/camps", params: { camp: @camp_attributes }, as: :json
    end

    assert_response :created
    camp = Camp.find(response.parsed_body["id"])
    assert_equal @camp_attributes[:name], camp.name
    assert_equal @camp_attributes[:description], camp.description
    assert_not camp.active
    assert camp.authenticate(@camp_attributes[:password])
    assert_not response.parsed_body.key?("password_digest")
  end

  test "invalid camp returns validation errors without being saved" do
    create_logged_in_admin

    assert_no_difference("Camp.count") do
      post "/camps", params: { camp: @camp_attributes.merge(name: "") }, as: :json
    end

    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"], "Name can't be blank"
  end

  test "anonymous request cannot create a camp" do
    assert_no_difference("Camp.count") do
      post "/camps", params: { camp: @camp_attributes }, as: :json
    end

    assert_redirected_to login_path
  end

  test "camp login cannot create a camp" do
    create_logged_in_camp

    assert_no_difference("Camp.count") do
      post "/camps", params: { camp: @camp_attributes }, as: :json
    end

    assert_redirected_to login_path
  end
end

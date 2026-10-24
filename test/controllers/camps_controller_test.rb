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

  def setup
    @camp_attributes = attributes_for(:camp, active: false)
  end

  test "admin can get the new camp form with all teams" do
    create_logged_in_admin
    teams = [create(:team, name: "Z Team"), create(:team, name: "A Team")]

    get new_camp_path

    assert_response :success
    assert_equal "text/html", response.media_type
    assert_select "h1", "New Camp"
    assert_select "form[action=?][method=post]", camps_path do
      assert_select "input[name='camp[name]'][required]"
      assert_select "textarea[name='camp[description]'][required]"
      assert_select "input[type=checkbox][name='camp[team_ids][]']", count: teams.size
      teams.each do |team|
        assert_select "input[type=checkbox][name='camp[team_ids][]'][value=?]", team.id.to_s
        assert_select "label", text: team.name
      end
      assert_select "input[type=checkbox][name='camp[active]'][checked]", count: 1
      assert_select "input[type=hidden][name='camp[active]'][value='0']"
      assert_select "input[type=password][name='camp[password]'][required]"
      assert_select "input[type=password][name='camp[password_confirmation]'][required]"
      assert_select "input[type=submit][value='Create camp']"
    end
    assert_equal ["A Team", "Z Team"], css_select("fieldset label").map(&:text)
  end

  test "admin can create an active camp without teams" do
    create_logged_in_admin

    assert_difference("Camp.count", 1) do
      assert_no_difference("CampAssignment.count") do
        post camps_path, params: { camp: @camp_attributes.merge(active: "1", team_ids: [""]) }
      end
    end

    assert_redirected_to new_camp_path
    camp = Camp.find_by!(name: @camp_attributes[:name])
    assert camp.active?
    assert_empty camp.teams
  end

  test "invalid camp returns validation errors without being saved" do
    create_logged_in_admin
    selected_team = create(:team)
    unselected_team = create(:team)
    camp_attributes = @camp_attributes.merge(name: "", active: "0", team_ids: ["", selected_team.id.to_s])

    assert_no_difference("Camp.count") do
      assert_no_difference("CampAssignment.count") do
        post camps_path, params: { camp: camp_attributes }
      end
    end

    assert_response :unprocessable_content
    assert_equal "text/html", response.media_type
    assert_select "[role=alert] li", text: "Name can't be blank"
    assert_select "input[name='camp[name]'][value='']"
    assert_select "textarea[name='camp[description]']", text: @camp_attributes[:description]
    assert_select "input[type=checkbox][name='camp[team_ids][]'][value=?][checked]", selected_team.id.to_s
    assert_select "input[type=checkbox][name='camp[team_ids][]'][value=?]:not([checked])", unselected_team.id.to_s
    assert_select "input[type=checkbox][name='camp[active]'][checked]", count: 0
    assert_select "input[type=password][value]", count: 0
  end

  test "camp requires a password and matching confirmation" do
    create_logged_in_admin

    [{ password: "" }, { password_confirmation: "different" }].each do |invalid_attributes|
      assert_no_difference("Camp.count") do
        post camps_path, params: { camp: @camp_attributes.merge(invalid_attributes) }
      end

      assert_response :unprocessable_content
      assert_select "[role=alert] li", text: /Password/
    end
  end

  test "anonymous request cannot create a camp" do
    assert_no_difference("Camp.count") do
      post camps_path, params: { camp: @camp_attributes }
    end

    assert_redirected_to login_path
  end

  test "camp login cannot create a camp" do
    create_logged_in_camp

    assert_no_difference("Camp.count") do
      post camps_path, params: { camp: @camp_attributes }
    end

    assert_redirected_to login_path
  end
end

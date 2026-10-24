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

  test "admin can edit a camp with its current details and team assignments" do
    @camp = create(:camp)
    create_logged_in_admin
    selected_team = create(:team, name: "Z Team", camps: [@camp])
    unselected_team = create(:team, name: "A Team")

    get edit_camp_path(@camp)

    assert_response :success
    assert_equal "text/html", response.media_type
    assert_select "h1", "Edit Camp"
    assert_select "form[action=?][method=post]", camp_path(@camp) do
      assert_select "input[type=hidden][name=_method][value=patch]"
      assert_select "input[name='camp[name]'][value=?]", @camp.name
      assert_select "textarea[name='camp[description]']", text: @camp.description
      assert_select "input[type=checkbox][name='camp[team_ids][]']", count: 2
      assert_select "input[type=checkbox][name='camp[team_ids][]'][value=?][checked]", selected_team.id.to_s
      assert_select "input[type=checkbox][name='camp[team_ids][]'][value=?]:not([checked])", unselected_team.id.to_s
      assert_select "input[type=checkbox][name='camp[active]'][checked]", count: 1
      assert_select "input[type=hidden][name='camp[active]'][value='0']"
      assert_select "input[type=password][required]", count: 0
      assert_select "input[type=password][value]", count: 0
      assert_select "input[type=submit][value='Save camp']"
    end
    assert_equal ["A Team", "Z Team"], css_select("fieldset label").map(&:text)
    assert_not_includes response.body, @camp.password_digest
  end

  test "edit form leaves the active checkbox unchecked for inactive camps" do
    @camp = create(:camp)
    create_logged_in_admin
    @camp.update!(active: false)

    get edit_camp_path(@camp)

    assert_response :success
    assert_select "input[type=checkbox][name='camp[active]']", count: 1
    assert_select "input[type=checkbox][name='camp[active]'][checked]", count: 0
  end

  test "admin can update camp details and replace teams without changing its password" do
    @camp = create(:camp)
    create_logged_in_admin
    create(:team, camps: [@camp])
    selected_teams = create_list(:team, 2)
    original_digest = @camp.password_digest

    assert_no_difference("Camp.count") do
      patch camp_path(@camp), params: {
        camp: {
          name: "Updated camp", description: "Updated description", active: "0",
          team_ids: ["", *selected_teams.map { |team| team.id.to_s }],
          password: "", password_confirmation: ""
        }
      }
    end

    assert_response :see_other
    assert_redirected_to edit_camp_path(@camp)
    assert_equal "Camp updated successfully", flash[:success]
    assert_equal "Updated camp", @camp.reload.name
    assert_equal "Updated description", @camp.description
    assert_not @camp.active?
    assert_equal selected_teams.map(&:id).sort, @camp.team_ids.sort
    assert_equal original_digest, @camp.password_digest
    assert @camp.authenticate("password")

    follow_redirect!

    assert_response :success
    assert_equal "text/html", response.media_type
    assert_select "input[name='camp[name]'][value='Updated camp']"
    assert_not_includes response.body, @camp.password_digest
  end

  test "admin can unassign all teams and activate a camp" do
    @camp = create(:camp)
    create_logged_in_admin
    create(:team, camps: [@camp])
    @camp.update!(active: false)

    patch camp_path(@camp), params: { camp: { team_ids: [""], active: "1" } }

    assert_redirected_to edit_camp_path(@camp)
    assert_empty @camp.reload.teams
    assert @camp.active?
  end

  test "invalid update renders errors and submitted values without saving any changes" do
    @camp = create(:camp)
    create_logged_in_admin
    original_name = @camp.name
    existing_team = create(:team, camps: [@camp])
    selected_team = create(:team)

    assert_no_difference("CampAssignment.count") do
      patch camp_path(@camp), params: {
        camp: { name: "", description: "Submitted description", active: "0", team_ids: ["", selected_team.id.to_s] }
      }
    end

    assert_response :unprocessable_content
    assert_equal "text/html", response.media_type
    assert_select "[role=alert] li", text: "Name can't be blank"
    assert_select "input[name='camp[name]'][value='']"
    assert_select "textarea[name='camp[description]']", text: "Submitted description"
    assert_select "input[type=checkbox][name='camp[team_ids][]'][value=?][checked]", selected_team.id.to_s
    assert_select "input[type=checkbox][name='camp[team_ids][]'][value=?]:not([checked])", existing_team.id.to_s
    assert_select "input[type=checkbox][name='camp[active]'][checked]", count: 0
    assert_equal original_name, @camp.reload.name
    assert_not_equal "Submitted description", @camp.description
    assert @camp.active?
    assert_equal [existing_team.id], @camp.team_ids
  end

  test "missing camp returns not found for edit and update" do
    @camp = create(:camp)
    create_logged_in_admin
    missing_id = Camp.maximum(:id).to_i + 1

    get edit_camp_path(missing_id)

    assert_response :not_found

    patch camp_path(missing_id), params: { camp: { name: "Updated camp" } }

    assert_response :not_found
  end

  test "guests cannot edit or update a camp" do
    @camp = create(:camp)
    original_name = @camp.name

    get edit_camp_path(@camp)

    assert_redirected_to login_path

    patch camp_path(@camp), params: { camp: { name: "Updated camp" } }

    assert_redirected_to login_path
    assert_equal original_name, @camp.reload.name
  end

  test "camp login cannot edit or update its own camp or another camp" do
    @camp = create(:camp)
    logged_in_camp = create_logged_in_camp

    [logged_in_camp, @camp].each do |camp|
      original_name = camp.name

      get edit_camp_path(camp)

      assert_redirected_to login_path
      assert_equal "You must be logged in as an admin to access this page", flash[:error]

      patch camp_path(camp), params: { camp: { name: "Updated camp" } }

      assert_redirected_to login_path
      assert_equal original_name, camp.reload.name
    end
  end
end

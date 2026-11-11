require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @camp = create_logged_in_camp
    @team = create(:team, name: "T1", camp: @camp)

    create(:camp_registration, camp: @camp, team: @team, player: create(:player, name: "A"))
    create(:camp_registration, camp: @camp, team: @team, player: create(:player, name: "B"))
  end

  test "does not allow access when not logged in" do
    log_out_user

    get camp_team_path(@camp, @team)

    assert_redirected_to login_path
  end

  test "show allows access when logged in as camp" do
    get camp_team_path(@camp, @team)

    assert_response :success
  end

  test "show allows access when logged in as admin" do
    create_logged_in_admin

    get camp_team_path(@camp, @team)

    assert_response :success
  end

  test "show renders breadcrumbs" do
    get camp_team_path(@camp, @team)

    assert_select ".breadcrumbs", count: 1
  end

  test "show displays team name and players when logged in as camp" do
    get camp_team_path(@camp, @team)

    assert_select "section[aria-labelledby='team-details-heading']"
    assert_select "h1#team-details-heading", "Team Details"
    assert_select "section[aria-labelledby='team-details']"
    assert_select "h2#team-name", "Name"
    assert_select "h2#players-heading", "Players"
    assert_select "#players li", "A"
    assert_select "#players li", "B"
  end

  test "show displays team name and players when logged in as admin" do
    create_logged_in_admin

    get camp_team_path(@camp, @team)

    assert_select "h1#team-details-heading", "Team Details"
    assert_select "div", text: "T1", count: 1
    assert_select "#players li", "A"
    assert_select "#players li", "B"
  end

  test "show renders the team details modal for a Turbo Stream request" do
    get camp_team_path(@camp, @team), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action='replace'][target='modal']"
    assert_includes response.body, 'id="modal"'
    assert_includes response.body, 'role="dialog"'
    assert_includes response.body, 'aria-modal="true"'
    assert_includes response.body, 'aria-labelledby="modal_title"'
    assert_includes response.body, '<h2 id="modal_title"'
    assert_includes response.body, "Team Details"
    assert_includes response.body, 'aria-label="Close"'
    assert_includes response.body, "A"
    assert_includes response.body, "B"
  end

  test "shows team name and no players" do
    team = create(:team, name: "T2", camp: @camp)

    get camp_team_path(@camp, team)

    assert_select "div", text: "T2", count: 1
    assert_select "#players"
    assert_select "#players li", count: 0
  end

  test "returns not found when a team that does not exist is requested" do
    get camp_team_path(@camp, 0)

    assert_response :not_found
  end

  test "logged in camp user can see team names on the camp page" do
    team = create(:team, name: "Ontario U17", camp: @camp)

    get camp_path(@camp)

    assert_response :success
    assert_match team.name, response.body
  end

  test "Admin can access the new team page" do
    create_logged_in_admin

    get new_camp_team_path(@camp)

    assert_response :success
  end

  test "Admin can create a team and assign camp players to it" do
    players = create_list(:player, 2)
    players.each { |player| create(:camp_registration, camp: @camp, player: player) }
    create_logged_in_admin

    assert_difference "Team.count", 1 do
      post camp_teams_path(@camp), params: {
        team: { name: "Ontario U17", player_ids: players.map(&:id) }
      }
    end

    team = @camp.teams.find_by!(name: "Ontario U17")
    assert_equal @camp, team.camp
    assert_equal players.sort_by(&:id), team.players.sort_by(&:id)
    assert_redirected_to camp_path(@camp)
  end

  test "Admin fails to create a team with no name" do
    create_logged_in_admin

    assert_no_difference "Team.count" do
      post camp_teams_path(@camp), params: { team: { name: "" } }
    end

    assert_response :unprocessable_content
  end

  [
    { who: "A camp", logged_out: false, message: "You must be logged in as an admin to access this page" },
    { who: "A logged out user", logged_out: true, message: "You must be logged in to access this page" }
  ].each do |user|
    test "#{user[:who]} cannot access the new team page" do
      log_out_user if user[:logged_out]

      get new_camp_team_path(@camp)

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "#{user[:who]} cannot create a team" do
      log_out_user if user[:logged_out]

      assert_no_difference "Team.count" do
        post camp_teams_path(@camp), params: { team: { name: "Sneaky Team" } }
      end

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "#{user[:who]} cannot access the edit team page" do
      log_out_user if user[:logged_out]

      get edit_camp_team_path(@camp, @team)

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "#{user[:who]} cannot update a team" do
      log_out_user if user[:logged_out]

      patch camp_team_path(@camp, @team), params: { team: { name: "Hacked" } }

      assert_redirected_to login_path
      assert_equal "T1", @team.reload.name
      assert_equal user[:message], flash[:error]
    end
  end

  test "destroy deletes the team" do
    create_logged_in_admin
    team = create(:team, camp: @camp)

    assert_difference("Team.count", -1) { delete camp_team_path(@camp, team) }

    assert_redirected_to camp_path(@camp)
    assert_equal "Team deleted successfully", flash[:success]
  end

  test "destroy does not delete a team with games" do
    create_logged_in_admin
    team = create(:team, :with_games, camp: @camp)

    assert_no_difference("Team.count") { delete camp_team_path(@camp, team) }

    assert_redirected_to camp_path(@camp)
    assert_equal "Cannot delete record because dependent games exist", flash[:error]
  end

  test "destroy redirects camp users" do
    team = create(:team, camp: @camp)

    assert_no_difference("Team.count") { delete camp_team_path(@camp, team) }

    assert_redirected_to login_path
  end

  test "destroy redirects logged out users" do
    log_out_user
    team = create(:team, camp: @camp)

    assert_no_difference("Team.count") { delete camp_team_path(@camp, team) }

    assert_redirected_to login_path
  end

  test "Admin can access the team edit page" do
    create_logged_in_admin

    get edit_camp_team_path(@camp, @team)

    assert_response :success
  end

  test "edit team has correct content" do
    create_logged_in_admin
    player = create(:player)
    team = create(:team, name: "One", camp: @camp)
    create(:camp_registration, camp: @camp, team: team, player: player)

    get edit_camp_team_path(@camp, team)

    assert_select "input[name='team[name]'][value='One']"
    assert_select "input[name='team[player_ids][]'][value='#{player.id}']"
  end

  test "search returns matching players" do
    create_logged_in_admin
    create(:player, name: "Alice")
    get search_players_path(q: "Ali")
    assert_response :success
    assert_match "Alice", response.body
  end

  test "Admin can update a team name and roster" do
    create_logged_in_admin
    team = create(:team, name: "One", camp: @camp)
    old = create(:player)
    create(:camp_registration, camp: @camp, team: team, player: old)
    players = create_list(:player, 2)
    players.each { |player| create(:camp_registration, camp: @camp, player: player) }

    patch camp_team_path(@camp, team), params: { team: { name: "New", player_ids: players.map(&:id) } }

    assert_redirected_to camp_path(@camp)
    assert_equal "New", team.reload.name
    assert_equal players.sort_by(&:id), team.players.sort_by(&:id)
    assert_nil old.camp_registrations.first.reload.team_id
  end

  test "Admin fails to update a team with no name" do
    create_logged_in_admin

    patch camp_team_path(@camp, @team), params: { team: { name: "", player_ids: [] } }

    assert_response :unprocessable_content
    assert_equal "T1", @team.reload.name
  end

  test "new renders the form in a modal for turbo stream requests" do
    create_logged_in_admin

    get new_camp_team_path(@camp), as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_turbo_stream action: :replace, target: "modal" do
      assert_select "#modal_title"
      assert_select "form[action=?]", camp_teams_path(@camp)
      assert_select "input[name='team[name]']"
    end
  end

  test "edit renders the form in a modal for turbo stream requests" do
    create_logged_in_admin
    team = create(:team, name: "A", camp: @camp)

    get edit_camp_team_path(@camp, team), as: :turbo_stream

    assert_response :success
    assert_turbo_stream action: :replace, target: "modal" do
      assert_select "#modal_title", text: "Edit team"
      assert_select "input[name='team[name]'][value=?]", "A"
    end
  end
end

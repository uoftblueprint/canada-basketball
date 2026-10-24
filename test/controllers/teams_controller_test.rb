require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @camp = create(:camp, password: "password")
    @team1 = create(:team, name: "T1")
    @admin = create(:admin, email: "admin@test.com", password: "password")

    create(:player, name: "A", team: @team1)
    create(:player, name: "B", team: @team1)
  end

  test "does not allow access when not logged in" do
    get team_path(@team1)
    assert_redirected_to login_path
  end

  test "show allow access when logged in as camp" do
    post login_path, params: { camp_id: @camp.id, password: "password" }

    get team_path(@team1)

    assert_response :success
  end

  test "shows allows access when logged in as admin" do
    post login_admin_path, params: { email: "admin@test.com", password: "password" }

    get team_path(@team1)

    assert_response :success
  end

  test "show displays team name and players when logged in as camp" do
    post login_path, params: { camp_id: @camp.id, password: "password" }

    get team_path(@team1)

    assert_select "h1", "T1"
    assert_select "li", "A"
    assert_select "li", "B"
  end

  test "show displays team name and players when logged in as admin" do
    post login_admin_path, params: { email: "admin@test.com", password: "password" }

    get team_path(@team1)

    assert_select "h1", "T1"
    assert_select "li", "A"
    assert_select "li", "B"
  end

  test "shows team name and no players" do
    team = create(:team, name: "T2")
    post login_path, params: { camp_id: @camp.id, password: "password" }

    get team_path(team)

    assert_select "h1", "T2"
    assert_select "players-list li", count: 0
  end

  test "returns not found when a team that does not exist is requested" do
    post login_path, params: { camp_id: @camp.id, password: "password" }

    get team_path(0)
    assert_response :not_found
  end

  test "Logged in user can see team names" do
    team = create(:team, name: "Ontario U17")
    log_in_as_camp

    get teams_path

    assert_response :success
    assert_match team.name, response.body
  end

  test "Logged out user is redirected to login from the teams index" do
    get teams_path

    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:error]
  end

  test "Admin can access the new team page" do
    log_in_as_admin

    get new_team_path
    assert_response :success
  end

  test "Admin can create a team" do
    players = create_list(:player, 2)
    log_in_as_admin

    assert_difference "Team.count", 1 do
      post teams_path, params: {
        team: { name: "Ontario U17", player_ids: players.map(&:id), camp_ids: [@camp.id] }
      }
    end

    team = Team.find_by!(name: "Ontario U17")
    assert_equal players.sort_by(&:id), team.players.sort_by(&:id)
    assert_equal [@camp], team.camps.to_a
  end

  test "Admin fails to create a team with no name" do
    log_in_as_admin

    assert_no_difference "Team.count" do
      post teams_path, params: { team: { name: "", player_ids: [], camp_ids: [] } }
    end
  end

  [
    { who: "A camp", logged_in_as_camp: true, message: "You must be logged in as an admin to access this page" },
    { who: "A logged out user", logged_in_as_camp: false, message: "You must be logged in to access this page" }
  ].each do |user|
    test "#{user[:who]} cannot access the new team page" do
      log_in_as_camp if user[:logged_in_as_camp]

      get new_team_path

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "#{user[:who]} cannot create a team" do
      log_in_as_camp if user[:logged_in_as_camp]

      assert_no_difference "Team.count" do
        post teams_path, params: { team: { name: "Sneaky Team" } }
      end

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end
  end

  private

  def log_in_as_admin
    post login_admin_path, params: { email: "admin@test.com", password: "password" }
  end

  def log_in_as_camp
    post login_path, params: { camp_id: @camp.id, password: "password" }
  end
end

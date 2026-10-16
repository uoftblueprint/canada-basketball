require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  # Setting up the virtual environment for testing teams
  def setup
    @admin = create(:admin, email: "admin@test.com", password: "password")
    @camp = create(:camp, password: "password")
    @team1 = create(:team, name: "T1")
    @team2 = create(:team, name: "T2")

    create(:player, name: "A", team: @team1)
    create(:player, name: "B", team: @team1)
  end

  # Tests that a user not logged in can not access the page
  test "does not allow access when not logged in" do
    get team_path(@team1)
    assert_redirected_to login_path
  end

  # Tests that name and players are properly displayed as an admin
  test "show displays team name and player when logged in as admin" do
    post login_admin_path, params: { email: "admin@test.com", password: "password" }

    get team_path(@team1)

    assert_response :success
    assert_select "h1", "T1"
    assert_select "li", "A"
    assert_select "li", "B"
  end

  # Tests that name and players are properly displayed as a camp
  test "show displays team name and player when logged in as camp" do
    post login_path, params: { camp_id: @camp.id, password: "password" }

    get team_path(@team1)

    assert_response :success
    assert_select "h1", "T1"
    assert_select "li", "A"
    assert_select "li", "B"
  end

  # Tests an empty team
  test "shows team name and no players" do
    post login_path, params: { camp_id: @camp.id, password: "password" }
    get team_path(@team2)

    assert_response :success
    assert_select "h1", "T2"
    assert_select "li", count: 0
  end

  # Tests on a team that does not exist
  test "returns not found when a team that does not exist is requested" do
    post login_path, params: { camp_id: @camp.id, password: "password" }

    get team_path(0)
    assert_response :not_found
  end
end

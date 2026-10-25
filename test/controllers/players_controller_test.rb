require "test_helper"

class PlayersControllerTest < ActionDispatch::IntegrationTest
  test "index is accessible by admins" do
    create_logged_in_admin

    get players_path

    assert_response :success
  end

  test "index is accessible by camp users" do
    create_logged_in_camp

    get players_path

    assert_response :success
  end

  test "index lists player names and teams" do
    create_logged_in_admin
    team1 = create(:team, name: "team1")
    team2 = create(:team, name: "team2")
    create(:player, name: "test_player_1", team: team1)
    create(:player, name: "test_player_2", team: team2)

    get players_path

    assert_select "tbody tr:first-child" do
      assert_select "td:first-child", text: "test_player_1"
      assert_select "td:last-child", text: "team1"
    end
    assert_select "tbody tr:nth-child(2)" do
      assert_select "td:first-child", text: "test_player_2"
      assert_select "td:last-child", text: "team2"
    end
  end

  test "index lists player names with no teams" do
    create_logged_in_admin
    create(:player, name: "test_player_3", team: nil)

    get players_path

    assert_select "td", text: "test_player_3"
    assert_select "td", text: "No Team"
  end

  test "index redirects logged out users" do
    get players_path

    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:error]
  end

  test "index displays a message when there are no players" do
    create_logged_in_admin

    get players_path

    assert_response :success
    assert_select "p", text: "No players yet."
    assert_select "tbody tr", count: 0
  end

  test "destroy deletes the player" do
    create_logged_in_admin
    player = create(:player)

    assert_difference("Player.count", -1) { delete player_path(player) }

    assert_redirected_to root_path
    assert_equal "Player deleted successfully", flash[:success]
  end

  test "destroy redirects camp users" do
    create_logged_in_camp
    player = create(:player)

    assert_no_difference("Player.count") { delete player_path(player) }

    assert_redirected_to login_path
  end

  test "destroy redirects logged out users" do
    player = create(:player)

    assert_no_difference("Player.count") { delete player_path(player) }

    assert_redirected_to login_path
  end
end

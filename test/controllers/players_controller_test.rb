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

  test "index lists player names" do
    create_logged_in_admin
    create(:player, name: "test_player_1")
    create(:player, name: "test_player_2")

    get players_path

    assert_select "#players_index_table .grid > div", text: "test_player_1"
    assert_select "#players_index_table .grid > div", text: "test_player_2"
  end

  test "index links to the player details modal" do
    create_logged_in_admin
    player = create(:player)

    get players_path

    assert_select 'a[href=?][data-turbo-stream="true"]', player_path(player), count: 1
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
    assert_select "#players_index_table span", text: I18n.t("shared.index_table_component.no_entries")
  end

  test "new is accessible by admins" do
    create_logged_in_admin

    get new_player_path

    assert_response :success
    assert_select 'input[name="player[name]"]'
  end

  test "new renders the form in a modal for turbo stream requests" do
    create_logged_in_admin

    get new_player_path, as: :turbo_stream

    assert_response :success
    assert_turbo_stream action: :replace, target: "modal" do
      assert_select "#modal_title", text: "New Player"
      assert_select 'input[name="player[name]"]'
    end
  end

  test "create adds the player" do
    create_logged_in_admin

    assert_difference("Player.count", 1) do
      post players_path, params: { player: { name: "test_name" } }
    end

    assert_redirected_to players_path
    assert_response :see_other
    assert_equal I18n.t("players.create.success"), flash[:success]
    assert_equal "test_name", Player.last.name
  end

  test "create does not allow player with blank name" do
    create_logged_in_admin

    assert_no_difference("Player.count") do
      post players_path, params: { player: { name: "" } }
    end

    assert_response :unprocessable_content
    assert_select 'input[name="player[name]"]'
    assert_equal "Name can't be blank", flash[:error]
  end

  test "new redirects camp users" do
    create_logged_in_camp

    get new_player_path

    assert_redirected_to login_path
  end

  test "new redirects logged out users" do
    get new_player_path

    assert_redirected_to login_path
  end

  test "create redirects camp users" do
    create_logged_in_camp

    assert_no_difference("Player.count") do
      post players_path, params: { player: { name: "test_name" } }
    end

    assert_redirected_to login_path
  end

  test "create redirects logged out users" do
    assert_no_difference("Player.count") do
      post players_path, params: { player: { name: "test_name" } }
    end

    assert_redirected_to login_path
  end

  test "show displays player details for admins" do
    create_logged_in_admin
    player = create(:player)

    get player_path(player)

    assert_response :success
    assert_select "section[aria-labelledby='player-details-heading']"
    assert_select "h1#player-details-heading", "Player Details"
    assert_select "section[aria-labelledby='player-details']"
    assert_select "h2#player-name", "Name"
    assert_select "div", text: player.name, count: 1
    assert_select "h2#registrations-heading", "Registrations"
    assert_select "#registrations li", count: 0
  end

  test "show renders breadcrumbs" do
    create_logged_in_admin
    player = create(:player)

    get player_path(player)

    assert_select ".breadcrumbs", count: 1
  end

  test "show displays registrations with their camps and teams" do
    create_logged_in_admin
    player = create(:player, name: "Shai Gilgeous-Alexander")
    camp_one = create(:camp, name: "Camp 1")
    camp_two = create(:camp, name: "Camp 2")
    team = create(:team, name: "Team 1", camp: camp_one)
    create(:camp_registration, player: player, camp: camp_one, team: team)
    create(:camp_registration, player: player, camp: camp_two)

    get player_path(player)

    assert_select "#registrations li", count: 2
    assert_select "#registrations li", text: "Camp 1 / Team 1"
    assert_select "#registrations li", text: "Camp 2 / No team"
  end

  test "show renders the player details modal for a Turbo Stream request" do
    create_logged_in_camp
    player = create(:player, name: "Shai Gilgeous-Alexander")
    camp = create(:camp, name: "Blue 1")
    team = create(:team, name: "Team 1", camp: camp)
    create(:camp_registration, player: player, camp: camp, team: team)

    get player_path(player), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action='replace'][target='modal']"
    assert_includes response.body, 'id="modal"'
    assert_includes response.body, 'role="dialog"'
    assert_includes response.body, 'aria-modal="true"'
    assert_includes response.body, 'aria-labelledby="modal_title"'
    assert_includes response.body, '<h2 id="modal_title"'
    assert_includes response.body, "Player Details"
    assert_includes response.body, 'aria-label="Close"'
    assert_includes response.body, "Blue 1 / Team 1"
  end

  test "show is accessible by camp users" do
    create_logged_in_camp
    player = create(:player)

    get player_path(player)

    assert_response :success
  end

  test "show redirects logged out users" do
    player = create(:player)
    get player_path(player)

    assert_redirected_to login_path
  end

  test "show handles non-existent id" do
    create_logged_in_admin

    get player_path(-1)
    assert_response :not_found
  end

  test "destroy deletes the player" do
    create_logged_in_admin
    player = create(:player)

    assert_difference("Player.count", -1) { delete player_path(player) }

    assert_redirected_to players_path
    assert_equal I18n.t("players.destroy.success"), flash[:success]
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

  test "admin can access the edit player page" do
    create_logged_in_admin
    player = create(:player)

    get edit_player_path(player)

    assert_response :success
    assert_select "input[name='player[name]'][value=?]", player.name
  end

  test "admin can update a player" do
    create_logged_in_admin
    player = create(:player)

    patch player_path(player), params: { player: { name: "New Name" } }

    assert_redirected_to player_path(player)
    assert_equal I18n.t("players.update.success"), flash[:success]
    assert_equal "New Name", player.reload.name
  end

  test "admin fails to update a player with no name" do
    create_logged_in_admin
    player = create(:player)

    patch player_path(player), params: { player: { name: "" } }

    assert_response :unprocessable_content
    assert_not_equal "", player.reload.name
  end

  [
    { who: "camp users", logged_in: :create_logged_in_camp,
      message: "You must be logged in as an admin to access this page" },
    { who: "logged out users", logged_in: nil,
      message: "You must be logged in to access this page" }
  ].each do |user|
    test "edit redirects #{user[:who]}" do
      send(user[:logged_in]) if user[:logged_in]
      player = create(:player)

      get edit_player_path(player)

      assert_redirected_to login_path
      assert_equal user[:message], flash[:error]
    end

    test "update redirects #{user[:who]}" do
      send(user[:logged_in]) if user[:logged_in]
      player = create(:player)

      patch player_path(player), params: { player: { name: "Hacked" } }

      assert_redirected_to login_path
      assert_not_equal "Hacked", player.reload.name
      assert_equal user[:message], flash[:error]
    end
  end
end

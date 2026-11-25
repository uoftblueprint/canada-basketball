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

  test "index lists player profile fields" do
    create_logged_in_admin
    create(:player, birth_year: 2006, height_cm: 198, province: "BC", hometown: "Victoria")

    get players_path

    assert_select "#players_index_table .grid > div", text: "2006"
    assert_select "#players_index_table .grid > div", text: "198"
    assert_select "#players_index_table .grid > div", text: "British Columbia"
    assert_select "#players_index_table .grid > div", text: "Victoria"
  end

  test "index marks missing profile fields as not provided" do
    create_logged_in_admin
    create(:player, birth_year: nil, height_cm: nil, province: nil, hometown: nil)

    get players_path

    assert_select "#players_index_table span.text-base-300", text: "Not provided"
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
    assert_equal I18n.t("authentication.require_login"), flash[:error]
  end

  test "index displays a message when there are no players" do
    create_logged_in_admin

    get players_path

    assert_response :success
    assert_select "#players_index_table span", text: I18n.t("shared.index_table_component.no_entries")
  end

  test "index csv lists player names" do
    create_logged_in_admin
    create(:player, name: "test_player_1")

    get players_path(format: :csv)

    assert_includes response.body, "test_player_1"
  end

  test "index csv includes player profile fields" do
    create_logged_in_admin
    create(:player, name: "test_player_1", birth_year: 2006, height_cm: 198, province: "BC", hometown: "Victoria")

    get players_path(format: :csv)

    rows = CSV.parse(response.body, headers: true)
    assert_equal %w[id name created_at updated_at birth_year height_cm province hometown], rows.headers
    assert_equal %w[test_player_1 2006 198 BC Victoria],
                 rows.first.fields("name", "birth_year", "height_cm", "province", "hometown")
  end

  test "new is accessible by admins" do
    create_logged_in_admin

    get new_player_path

    assert_response :success
    assert_select 'input[name="player[name]"]'
    assert_select 'input[type="number"][name="player[birth_year]"]'
    assert_select 'input[type="number"][name="player[height_cm]"]'
    assert_select 'select[name="player[province]"] option', count: Player::PROVINCES.size + 1
    assert_select 'select[name="player[province]"] option[value="QC"]', text: "Quebec"
    assert_select 'input[name="player[hometown]"]'
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

  test "create saves the player profile fields" do
    create_logged_in_admin

    post players_path, params: {
      player: { name: "test_name", birth_year: "2007", height_cm: "201", province: "MB", hometown: "Winnipeg" }
    }

    player = Player.last
    assert_equal 2007, player.birth_year
    assert_equal 201, player.height_cm
    assert_equal "MB", player.province
    assert_equal "Winnipeg", player.hometown
  end

  test "create stores blank profile fields as nil" do
    create_logged_in_admin

    post players_path, params: {
      player: { name: "test_name", birth_year: "", height_cm: "", province: "", hometown: "" }
    }

    assert_redirected_to players_path
    assert_equal [nil, nil, nil, nil], Player.last.slice(:birth_year, :height_cm, :province, :hometown).values
  end

  test "create does not allow a player with an invalid height" do
    create_logged_in_admin

    assert_no_difference("Player.count") do
      post players_path, params: { player: { name: "test_name", height_cm: "30" } }
    end

    assert_response :unprocessable_content
    assert_equal "Height (cm) must be greater than 50", flash[:error]
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

  test "show displays player profile fields" do
    create_logged_in_admin
    player = create(:player, birth_year: 2006, height_cm: 198, province: "BC", hometown: "Victoria")

    get player_path(player)

    assert_select "h2#player-birth-year", "Year of Birth"
    assert_select "div[aria-labelledby='player-birth-year']", text: "2006"
    assert_select "h2#player-height-cm", "Height (cm)"
    assert_select "div[aria-labelledby='player-height-cm']", text: "198"
    assert_select "h2#player-province", "Province"
    assert_select "div[aria-labelledby='player-province']", text: "British Columbia"
    assert_select "h2#player-hometown", "Hometown"
    assert_select "div[aria-labelledby='player-hometown']", text: "Victoria"
  end

  test "show marks missing profile fields as not provided" do
    create_logged_in_admin
    player = create(:player, birth_year: nil, height_cm: nil, province: nil, hometown: nil)

    get player_path(player)

    assert_select "div[aria-labelledby^='player-']", text: "Not provided", count: 4
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
    assert_select "input[name='player[birth_year]'][value=?]", player.birth_year.to_s
    assert_select "input[name='player[height_cm]'][value=?]", player.height_cm.to_s
    assert_select "select[name='player[province]'] option[selected][value=?]", player.province
    assert_select "input[name='player[hometown]'][value=?]", player.hometown
  end

  test "edit renders the form in a modal for turbo stream requests" do
    create_logged_in_admin
    player = create(:player)

    get edit_player_path(player), as: :turbo_stream

    assert_response :success
    assert_turbo_stream action: :replace, target: "modal" do
      assert_select "#modal_title", text: "Edit Player"
      assert_select "input[name='player[name]'][value=?]", player.name
    end
  end

  test "admin can update a player" do
    create_logged_in_admin
    player = create(:player)

    patch player_path(player), params: { player: { name: "New Name" } }

    assert_redirected_to player_path(player)
    assert_equal I18n.t("players.update.success"), flash[:success]
    assert_equal "New Name", player.reload.name
  end

  test "admin can update a player's profile fields" do
    create_logged_in_admin
    player = create(:player)

    patch player_path(player), params: {
      player: { birth_year: "2004", height_cm: "175", province: "NS", hometown: "Halifax" }
    }

    assert_redirected_to player_path(player)
    player.reload
    assert_equal [2004, 175, "NS", "Halifax"], [player.birth_year, player.height_cm, player.province, player.hometown]
  end

  test "admin fails to update a player with an invalid province" do
    create_logged_in_admin
    player = create(:player, province: "ON")

    patch player_path(player), params: { player: { province: "XX" } }

    assert_response :unprocessable_content
    assert_equal "ON", player.reload.province
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
      message: I18n.t("authentication.require_admin") },
    { who: "logged out users", logged_in: nil,
      message: I18n.t("authentication.require_login") }
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

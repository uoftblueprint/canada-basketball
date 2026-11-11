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

    assert_operator response.body.index("B Camp"), :<, response.body.index("C Camp")
    assert_operator response.body.index("C Camp"), :<, response.body.index("A Camp")
    assert_select "h2", count: 3
    assert_select "h2", text: "B Camp"
    assert_select "h2", text: "C Camp"
    assert_select "h2", text: "A Camp"
    assert_select "span.badge", text: "Active", count: 2
    assert_select "span.badge", text: "Inactive", count: 1
  end

  test "index renders accessible search, pagination, and add camp controls" do
    create_logged_in_admin
    create(:camp)

    get camps_path

    assert_select "turbo-frame#camps_index_cards"
    assert_select "form label.sr-only", text: "Search Camps"
    assert_select "input[type='search'][placeholder='Search Camps']"
    assert_select "nav[aria-label='Camp pages']"
    assert_select "a[href='#{new_camp_path}']", text: /Add Camp/
  end

  test "index filters camps by search query" do
    create_logged_in_admin
    matching_camp = create(:camp, name: "Summer Camp")
    create(:camp, name: "Winter Camp")

    get camps_path, params: { camps: { q: "Summer" } }

    assert_select "h2", text: matching_camp.name
    assert_not_includes response.body, "Winter Camp"
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

  test "new is accessible by admins" do
    create_logged_in_admin

    get new_camp_path

    assert_response :success
  end

  test "new redirects camp users" do
    create_logged_in_camp

    get new_camp_path

    assert_redirected_to login_path
    assert_equal "You must be logged in as an admin to access this page", flash[:error]
  end

  test "new redirects logged out users" do
    get new_camp_path

    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:error]
  end

  test "create creates a camp" do
    create_logged_in_admin

    assert_difference("Camp.count", 1) do
      post camps_path, params: {
        camp: {
          name: "New Camp",
          description: "A new camp",
          password: "password",
          password_confirmation: "password",
          active: true
        }
      }
    end
    created_camp = Camp.order(:id).last

    assert_equal "New Camp", created_camp.name
    assert_equal "A new camp", created_camp.description
    assert created_camp.active
    assert_redirected_to camp_path(created_camp)
    assert_equal "Camp created successfully", flash[:success]
  end

  test "create does not create a camp with invalid input" do
    create_logged_in_admin

    assert_no_difference("Camp.count") do
      post camps_path, params: {
        camp: {
          name: "",
          description: "A new camp",
          password: "password",
          password_confirmation: "password",
          active: true
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create redirects camp users" do
    create_logged_in_camp

    assert_no_difference("Camp.count") do
      post camps_path, params: {
        camp: {
          name: "New Camp",
          description: "A new camp",
          password: "password",
          password_confirmation: "password",
          active: true
        }
      }
    end

    assert_redirected_to login_path
    assert_equal "You must be logged in as an admin to access this page", flash[:error]
  end

  test "create redirects logged out users" do
    assert_no_difference("Camp.count") do
      post camps_path, params: {
        camp: {
          name: "New Camp",
          description: "A new camp",
          password: "password",
          password_confirmation: "password",
          active: true
        }
      }
    end

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

  test "camp can access its own show page" do
    camp = create_logged_in_camp

    get camp_path(camp)

    assert_response :success
  end

  test "camp show page renders breadcrumbs" do
    camp = create_logged_in_camp

    get camp_path(camp)

    assert_select ".breadcrumbs", count: 1
    assert_select "a[href='#{camps_path}']", count: 0
  end

  test "admin camp show page links to camps" do
    camp = create(:camp)
    create_logged_in_admin

    get camp_path(camp)

    assert_select "a[href='#{camps_path}']", text: "Camps"
  end

  test "camp page shows players from every assigned team" do
    camp = create_logged_in_camp
    teams = create_list(:team, 2, camp: camp)
    registrations = teams.map { |team| create(:camp_registration, camp: camp, team: team) }
    unrelated_player = create(:player)

    get camp_path(camp)

    assert_response :success
    registrations.each do |registration|
      assert_select "turbo-frame#players_index_table div", text: registration.player.name
      assert_select "turbo-frame#players_index_table div", text: registration.team.name
    end
    assert_select "turbo-frame#players_index_table div", text: unrelated_player.name, count: 0
    assert_not_includes response.body, camp.password_digest
  end

  test "camp page shows only its games with teams and opponents" do
    camp = create_logged_in_camp
    active_game = create(:game, team: create(:team, camp: camp))
    inactive_game = create(:game, :inactive, team: create(:team, camp: camp))
    unrelated_game = create(:game)

    get camp_path(camp)

    assert_response :success
    [active_game, inactive_game].each do |game|
      assert_includes response.body, game.team.name
      assert_includes response.body, game.opponent_name
    end
    assert_not_includes response.body, unrelated_game.name
  end

  test "camp page renders searchable tables with row actions" do
    camp = create_logged_in_camp
    team = create(:team, camp: camp, name: "Team One")
    player = create(:player, name: "Player One")
    create(:camp_registration, camp: camp, player: player, team: team)
    game = create(:game, camp: camp, team: team, name: "Game One")

    get camp_path(camp)

    assert_response :success
    assert_select "section[aria-labelledby='teams-heading'] input[type='search'][aria-label='Search Teams']"
    assert_select "section[aria-labelledby='players-heading'] input[type='search'][aria-label='Search Players']"
    assert_select "section[aria-labelledby='games-heading'] input[type='search'][aria-label='Search Games']"

    assert_select "a[href='#{camp_team_path(camp, team)}']", text: "View"
    assert_select "a[href='#{edit_camp_team_path(camp, team)}']", text: "Edit"
    assert_select "form[action='#{camp_team_path(camp, team)}'][method='post'] input[name='_method'][value='delete']"

    assert_select "a[href='#{player_path(player)}']", text: "View"
    assert_select "a[href='#{camp_game_path(camp, game)}']", text: "View"
    assert_select "a[href='#{edit_camp_game_path(camp, game)}']", text: "Edit"
    assert_select "form[action='#{camp_game_path(camp, game)}'][method='post'] input[name='_method'][value='delete']"
  end

  test "camp page renders without players or games" do
    camp = create_logged_in_camp

    get camp_path(camp)

    assert_response :success
    assert_select "h1", camp.name
    assert_select "tbody tr", count: 0
  end

  test "guests must log in" do
    camp = create(:camp)

    get camp_path(camp)

    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:error]
  end

  test "camp cannot get another camp's page" do
    create_logged_in_camp
    other_camp = create(:camp)

    get camp_path(other_camp)

    assert_redirected_to login_path
    assert_equal "You don't have access to this camp", flash[:error]
  end
end

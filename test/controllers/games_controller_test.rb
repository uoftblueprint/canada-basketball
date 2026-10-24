require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "show displays the right game and edit button" do
    camp = create_logged_in_camp
    game = create(:game, camp: camp, name: "Test Game", opponent_name: "Pacers")

    get camp_game_path(camp, game)

    assert_response :success
    assert_select "h1", text: "Name: Test Game"
  end

  test "show does not allow access to another camp's game" do
    camp = create_logged_in_camp
    not_camp_game = create(:game)

    get camp_game_path(camp, not_camp_game)

    assert_response :not_found
  end

  test "create creates a game" do
    camp = create_logged_in_camp
    team = create(:team)
    camp.teams << team

    assert_difference("Game.count", 1) do
      post camp_games_path(camp), params: {
        game: { name: "Raptors", opponent_name: "Pistons", team_id: team.id }
      }
    end
    created_game = Game.order(:id).last

    assert_equal "Raptors", created_game.name
    assert_equal "Pistons", created_game.opponent_name
    assert_equal camp.id, created_game.camp_id
    assert_equal team.id, created_game.team_id
    assert_redirected_to camp_game_path(camp, created_game)
    follow_redirect!
    assert_select "h1", text: "Name: Raptors"
  end

  test "create doesn't create a game with invalid input" do
    camp = create_logged_in_camp
    team = create(:team)
    camp.teams << team

    assert_no_difference("Game.count") do
      post camp_games_path(camp), params: {
        game: { name: "", opponent_name: "Pistons", team_id: team.id }
      }
    end
    assert_response :unprocessable_entity
  end

  test "update changes a game's attributes" do
    camp = create_logged_in_camp
    game = create(:game, camp: camp, name: "Prev")

    patch camp_game_path(camp, game), params: {
      game: { name: "Updated", opponent_name: "Thunder" }
    }

    assert_equal "Updated", game.reload.name
    assert_equal "Thunder", game.reload.opponent_name
  end

  test "update doesn't change a game with invalid input" do
    camp = create_logged_in_camp
    game = create(:game, camp: camp, name: "Prev")

    patch camp_game_path(camp, game), params: {
      game: { name: "", opponent_name: "Pistons" }
    }

    assert_equal "Prev", game.reload.name
    assert_response :unprocessable_entity
  end

  test "destroy deletes a game" do
    camp = create_logged_in_camp
    game = create(:game, camp: camp)

    assert_difference("Game.count", -1) do
      delete camp_game_path(camp, game)
    end
  end
end

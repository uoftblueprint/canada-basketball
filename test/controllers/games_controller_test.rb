require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
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
end

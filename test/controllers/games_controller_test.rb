require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @camp = create_logged_in_camp
    @team = create(:team)
    @camp.teams << @team
  end

  test "create creates a game" do
    assert_difference("Game.count", 1) do
      post camp_games_path(@camp), params: {
        game: { name: "Raptors", opponent_name: "Pistons", team_id: @team.id }
      }
    end
    created_game = Game.order(:id).last

    assert_equal "Raptors", created_game.name
    assert_equal "Pistons", created_game.opponent_name
    assert_equal @camp.id, created_game.camp_id
    assert_equal @team.id, created_game.team_id
    assert_redirected_to camp_game_path(@camp, created_game)
  end

  test "create doesn't create a game with invalid input" do
    assert_no_difference("Game.count") do
      post camp_games_path(@camp), params: {
        game: { name: "", opponent_name: "Pistons", team_id: @team.id }
      }
    end
    assert_response :unprocessable_entity
  end

  test "logged out users cannot create a game" do
    log_out_user
    assert_no_difference("Game.count") do
      post camp_games_path(@camp), params: {
        game: { name: "Raptors", opponent_name: "Pistons", team_id: @team.id }
      }
    end
    assert_redirected_to login_path
  end

  test "camp cannot create a game for another camp" do
    other_camp = create(:camp)
    other_team = create(:team)
    other_camp.teams << other_team

    assert_no_difference("Game.count") do
      post camp_games_path(other_camp), params: {
        game: { name: "Raptors", opponent_name: "Pistons", team_id: other_team.id }
      }
    end
    assert_redirected_to root_path
  end

  test "camp cannot view another camp's new game form" do
    other_camp = create(:camp)
    get new_camp_game_path(other_camp)
    assert_redirected_to root_path
  end

  test "admin can create a game for  camp" do
    log_out_user
    create_logged_in_admin

    assert_difference("Game.count", 1) do
      post camp_games_path(@camp), params: {
        game: { name: "Raptors", opponent_name: "Pistons", team_id: @team.id }
      }
    end

    created_game = Game.order(:id).last

    assert_equal @camp.id, created_game.camp_id
    assert_equal @team.id, created_game.team_id
    assert_redirected_to camp_game_path(@camp, created_game)
  end
end

require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @camp = create_logged_in_camp
    @team = create(:team)
    @camp.teams << @team
  end

  test "show displays the right game and edit button" do
    game = create(:game, camp: @camp, name: "Test Game", opponent_name: "Pacers")

    get camp_game_path(@camp, game)

    assert_response :success
    assert_select "h1", text: "Name: Test Game"
  end

  test "show does not allow a game that doesn't exist in camp" do
    not_camp_game = create(:game)

    get camp_game_path(@camp, not_camp_game)

    assert_response :not_found
  end

  test "a camp cannot access another camps's game" do
    other_camp = create(:camp)
    game = create(:game, camp: other_camp)

    get camp_game_path(other_camp, game)

    assert_redirected_to root_path
  end

  test "logged out users cannot access a game" do
    log_out_user
    game = create(:game, camp: @camp, name: "Test Game", opponent_name: "Pacers")
    get camp_game_path(@camp, game)
    assert_redirected_to login_path
  end

  test "admin can access a camp game" do
    log_out_user
    create_logged_in_admin
    game = create(:game, camp: @camp, name: "Test Game", opponent_name: "Pacers")

    get camp_game_path(@camp, game)

    assert_response :success
    assert_select "h1", text: "Name: Test Game"
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

  test "admin can create a game for a camp" do
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

  test "update changes a game's attributes" do
    game = create(:game, camp: @camp, name: "Prev")

    patch camp_game_path(@camp, game), params: {
      game: { name: "Updated", opponent_name: "Thunder" }
    }

    assert_equal "Updated", game.reload.name
    assert_equal "Thunder", game.reload.opponent_name
  end

  test "update doesn't change a game with invalid input" do
    game = create(:game, camp: @camp, name: "Prev")

    patch camp_game_path(@camp, game), params: {
      game: { name: "", opponent_name: "Pistons" }
    }

    assert_equal "Prev", game.reload.name
    assert_response :unprocessable_entity
  end

  test "logged out users cannot update a game" do
    game = create(:game, camp: @camp, name: "Prev")
    log_out_user

    patch camp_game_path(@camp, game), params: {
      game: { name: "Updated", opponent_name: "Thunder" }
    }

    assert_equal "Prev", game.reload.name
    assert_redirected_to login_path
  end

  test "camp cannot update another camp's game" do
    other_camp = create(:camp)
    game = create(:game, camp: other_camp, name: "Prev")

    patch camp_game_path(other_camp, game), params: {
      game: { name: "Updated", opponent_name: "Thunder" }
    }

    assert_equal "Prev", game.reload.name
    assert_redirected_to root_path
  end

  test "admin can update a game's attributes" do
    game = create(:game, camp: @camp, name: "Prev")
    log_out_user
    create_logged_in_admin

    patch camp_game_path(@camp, game), params: {
      game: { name: "Updated", opponent_name: "Thunder" }
    }

    assert_equal "Updated", game.reload.name
  end

  test "destroy deletes a game" do
    camp = create_logged_in_camp
    game = create(:game, camp: camp)

    assert_difference("Game.count", -1) do
      delete camp_game_path(camp, game)
    end
  end

  test "logged out user cannot destroy a game" do
    log_out_user
    game = create(:game, camp: @camp)

    assert_no_difference("Game.count") do
      delete camp_game_path(@camp, game)
    end

    assert_redirected_to login_path
  end

  test "camp cannot destroy another camp's game through its own url" do
    other_camp = create(:camp)
    game = create(:game, camp: other_camp)

    assert_no_difference("Game.count") do
      delete camp_game_path(@camp, game)
    end

    assert_response :not_found
  end
  
  test "camp cannot destroy a game through another camp's URL" do
    other_camp = create(:camp)
    game = create(:game, camp: other_camp)

    assert_no_difference("Game.count") do
      delete camp_game_path(other_camp, game)
    end

    assert_redirected_to root_path
  end

  test "admin can destroy a game" do
    log_out_user
    create_logged_in_admin
    camp = create(:camp)
    game = create(:game, camp: camp)

    assert_difference("Game.count", -1) do
      delete camp_game_path(camp, game)
    end

    assert_response :see_other
  end
end

require "test_helper"

class PlayersControllerTest < ActionDispatch::IntegrationTest
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

require "test_helper"

class GameEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @camp = create_logged_in_camp
    @team = create(:team)
    @camp.teams << @team
    @game = create(:game, camp: @camp, team: @team)
    @player = create(:player)
    create(:camp_registration, camp: @camp, player: @player, team: @team)
  end

  test "create with a player subject creates a player game event" do
    assert_difference("GameEvent.count", 1) do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "two_point_made", period: "q1", subject: @player.id }
      }
    end

    event = GameEvent.order(:id).last
    assert_equal @player.id, event.player_id
    assert_not event.is_opponent
    assert_equal "two_point_made", event.kind
    assert_redirected_to box_score_camp_game_path(@camp, @game)
  end

  test "create with team subject creates a team game event" do
    assert_difference("GameEvent.count", 1) do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "assist", period: "q2", subject: "team" }
      }
    end

    event = GameEvent.order(:id).last
    assert_nil event.player_id
    assert_not event.is_opponent
    assert_redirected_to box_score_camp_game_path(@camp, @game)
  end

  test "create with opponent subject creates an opponent game event" do
    assert_difference("GameEvent.count", 1) do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "three_point_made", period: "q3", subject: "opponent" }
      }
    end

    event = GameEvent.order(:id).last
    assert_nil event.player_id
    assert event.is_opponent
    assert_redirected_to box_score_camp_game_path(@camp, @game)
  end

  test "create with invalid kind does not create an event" do
    assert_no_difference("GameEvent.count") do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "invalid", period: "q1", subject: "team" }
      }
    end

    assert_response :unprocessable_content
  end

  test "logged out user cannot create a game event" do
    log_out_user

    assert_no_difference("GameEvent.count") do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "two_point_made", period: "q1", subject: "team" }
      }
    end

    assert_redirected_to login_path
  end

  test "camp cannot create event for another camp's game" do
    other_camp = create(:camp)
    other_team = create(:team)
    other_camp.teams << other_team
    other_game = create(:game, camp: other_camp, team: other_team)

    assert_no_difference("GameEvent.count") do
      post camp_game_game_events_path(other_camp, other_game), params: {
        game_event: { kind: "two_point_made", period: "q1", subject: "team" }
      }
    end

    assert_redirected_to login_path
  end

  test "admin can create a game event" do
    log_out_user
    create_logged_in_admin

    assert_difference("GameEvent.count", 1) do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "steal", period: "q1", subject: "team" }
      }
    end

    assert_redirected_to box_score_camp_game_path(@camp, @game)
  end

  test "create broadcasts updated stat lines to both game views" do
    box_score_target = ActionView::RecordIdentifier.dom_id(@game, :box_score_stat_lines)
    show_target = ActionView::RecordIdentifier.dom_id(@game, :show_stat_lines)

    broadcasts = capture_turbo_stream_broadcasts(@game) do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "two_point_made", period: "q1", subject: @player.id }
      }
    end

    assert_equal 2, broadcasts.size
    assert(broadcasts.any? { |html| html.to_s.include?(%(target="#{box_score_target}")) })
    assert(broadcasts.any? { |html| html.to_s.include?(%(target="#{show_target}")) })
  end
end

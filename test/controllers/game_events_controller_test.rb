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
    assert_equal I18n.t("game_events.create.success"), flash[:success]
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

  test "turbo create replaces existing tables with recomputed player stats" do
    create(:game_event, game: @game, player: @player, kind: "two_point_missed")

    assert_difference("GameEvent.count", 1) do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "two_point_made", period: "q1", subject: @player.id }
      }, as: :turbo_stream
    end

    assert_box_score_replacements
    assert_includes response.body, @player.name
    assert_includes response.body, "50%"
  end

  test "turbo create displays team events and preserves player stats" do
    create(:game_event, game: @game, player: @player, kind: "two_point_made")

    post camp_game_game_events_path(@camp, @game), params: {
      game_event: { kind: "three_point_made", period: "q1", subject: "team" }
    }, as: :turbo_stream

    assert_box_score_replacements
    assert_includes response.body, @team.name
    assert_includes response.body, @player.name
    assert_includes response.body, "100%"
  end

  test "turbo create updates opponent stats" do
    post camp_game_game_events_path(@camp, @game), params: {
      game_event: { kind: "three_point_made", period: "q1", subject: "opponent" }
    }, as: :turbo_stream

    assert_box_score_replacements
    assert_includes response.body, @game.opponent_name
    assert_includes response.body, "100%"
  end

  test "invalid turbo create renders validation errors without adding an event" do
    assert_no_difference("GameEvent.count") do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "invalid", period: "q1", subject: "team" }
      }, as: :turbo_stream
    end

    assert_response :unprocessable_content
    assert_equal "text/html", response.media_type
    assert_includes response.body, I18n.t("errors.messages.inclusion")
  end

  private

  def assert_box_score_replacements
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    %i[events_table stat_lines_table].each do |table|
      assert_turbo_stream action: :replace, target: ActionView::RecordIdentifier.dom_id(@game, table)
    end
  end

  test "destroy deletes the game event" do
    event = create(:game_event, game: @game, player: @player)

    assert_difference("GameEvent.count", -1) do
      delete camp_game_game_event_path(@camp, @game, event)
    end

    assert_redirected_to box_score_camp_game_path(@camp, @game)
    assert_equal I18n.t("game_events.destroy.success"), flash[:success]
  end

  test "destroy with a missing event returns not found" do
    assert_no_difference("GameEvent.count") do
      delete camp_game_game_event_path(@camp, @game, id: 0)
    end

    assert_response :not_found
  end

  test "logged out user cannot destroy a game event" do
    event = create(:game_event, game: @game, player: @player)
    log_out_user

    assert_no_difference("GameEvent.count") do
      delete camp_game_game_event_path(@camp, @game, event)
    end

    assert_redirected_to login_path
  end

  test "camp cannot destroy an event from another camp's game" do
    other_camp = create(:camp)
    other_team = create(:team)
    other_camp.teams << other_team
    other_game = create(:game, camp: other_camp, team: other_team)
    event = create(:game_event, game: other_game, player: nil)

    assert_no_difference("GameEvent.count") do
      delete camp_game_game_event_path(other_camp, other_game, event)
    end

    assert_redirected_to login_path
  end

  test "admin can destroy a game event" do
    event = create(:game_event, game: @game, player: @player)
    log_out_user
    create_logged_in_admin

    assert_difference("GameEvent.count", -1) do
      delete camp_game_game_event_path(@camp, @game, event)
    end

    assert_redirected_to box_score_camp_game_path(@camp, @game)
  end
end

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

  test "turbo create replaces existing tables with recomputed player stats" do
    create(:game_event, game: @game, player: @player, kind: "two_point_missed")

    assert_difference("GameEvent.count", 1) do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "two_point_made", period: "q1", subject: @player.id }
      }, as: :turbo_stream
    end

    assert_box_score_replacements
    assert_select "turbo-stream[target='events_table_game_#{@game.id}'] template" do
      assert_select "form[action=?]", camp_game_game_event_path(@camp, @game, GameEvent.order(:id).last)
      assert_select "div", text: "Two point made"
    end
    assert_rendered_stat :stat_lines_table, @player.name, "PTS", "2"
    assert_rendered_stat :stat_lines_table, @player.name, "FG%", "50%"
  end

  test "turbo create displays team events and preserves player stats" do
    create(:game_event, game: @game, player: @player, kind: "two_point_made")

    post camp_game_game_events_path(@camp, @game), params: {
      game_event: { kind: "three_point_made", period: "q1", subject: "team" }
    }, as: :turbo_stream

    assert_box_score_replacements
    assert_rendered_stat :stat_lines_table, @player.name, "PTS", "2"
    assert_select "turbo-stream[target='events_table_game_#{@game.id}'] template" do
      assert_select "div", text: "Three point made"
      assert_select "div", text: @team.name
    end
  end

  test "turbo create updates opponent stats" do
    post camp_game_game_events_path(@camp, @game), params: {
      game_event: { kind: "three_point_made", period: "q1", subject: "opponent" }
    }, as: :turbo_stream

    assert_box_score_replacements
    assert_rendered_stat :stat_lines_table, @game.opponent_name, "PTS", "3"
  end

  test "invalid turbo create renders validation errors without adding an event" do
    assert_no_difference("GameEvent.count") do
      post camp_game_game_events_path(@camp, @game), params: {
        game_event: { kind: "invalid", period: "q1", subject: "team" }
      }, as: :turbo_stream
    end

    assert_response :unprocessable_content
    assert_equal "text/html", response.media_type
    assert_select "#events_table_game_#{@game.id}"
    assert_match "Kind is not included in the list", response.body
  end

  private

  def assert_box_score_replacements
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream", count: 2
    %i[events_table stat_lines_table].each do |table|
      id = ActionView::RecordIdentifier.dom_id(@game, table)
      assert_turbo_stream action: :replace, target: id do
        assert_select "template ##{id}", count: 1
      end
    end
  end

  def assert_rendered_stat(table, name, stat, value)
    id = ActionView::RecordIdentifier.dom_id(@game, table)
    cells = css_select("turbo-stream[target='#{id}'] template .grid > div").map { |cell| cell.text.strip }
    assert_includes cells, name
    assert_equal value, cells[cells.index(name) + cells.index(stat)]
  end
end

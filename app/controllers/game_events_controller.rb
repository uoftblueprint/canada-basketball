class GameEventsController < ApplicationController
  include IndexTable

  scope_to_camp

  def create
    @game = current_camp.games.find(params.expect(:game_id))
    @game_event = @game.game_events.new(game_event_params)

    resolve_subject

    if @game_event.save
      redirect_to box_score_camp_game_path(current_camp, @game),
                  flash: { success: t(".success") },
                  status: :see_other
    else
      flash.now[:error] = @game_event.errors.full_messages.to_sentence
      @stat_lines_state = build_table_state(@game.player_and_opponent_stat_lines,
                                            per_page: 50, param_scope: :stat_lines)
      render "games/box_score", status: :unprocessable_content
    end
  end

  private

  def game_event_params
    params.expect(game_event: %i[kind period])
  end

  def resolve_subject
    subject = params.dig(:game_event, :subject)

    case subject
    when "team"
      @game_event.player_id = nil
      @game_event.is_opponent = false
    when "opponent"
      @game_event.player_id = nil
      @game_event.is_opponent = true
    else
      @game_event.player_id = subject
      @game_event.is_opponent = false
    end
  end
end

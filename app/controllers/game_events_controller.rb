class GameEventsController < ApplicationController
  include IndexTable

  scope_to_camp

  def create
    @game = current_camp.games.find(params.expect(:game_id))
    @game_event = @game.game_events.new(game_event_params)

    resolve_subject

    if @game_event.save
      respond_to do |format|
        format.html do
          redirect_to box_score_camp_game_path(current_camp, @game),
                      flash: { success: t(".success") },
                      status: :see_other
        end
        format.turbo_stream do
          build_box_score_tables
        end
      end
    else
      build_box_score_tables
      flash.now[:error] = @game_event.errors.full_messages.to_sentence
      render "games/box_score", formats: [:html], status: :unprocessable_content
    end
  end

  def destroy
    @game = current_camp.games.find(params.expect(:game_id))
    game_event = @game.game_events.find(params.expect(:id))

    if game_event.destroy
      redirect_to box_score_camp_game_path(current_camp, @game),
                  flash: { success: t(".success") },
                  status: :see_other
    else
      redirect_to box_score_camp_game_path(current_camp, @game),
                  flash: { error: game_event.errors.full_messages.to_sentence },
                  status: :see_other
    end
  end

  private

  def build_box_score_tables
    @game_events_state = build_events_table
    @stat_lines_state = build_stat_lines_state
  end

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

  def build_stat_lines_state
    build_table_state(@game.player_and_opponent_stat_lines, per_page: 50, param_scope: :stat_lines)
  end

  def build_events_table
    build_table_state(@game.game_events.includes(:player).order(created_at: :desc, id: :desc),
                      per_page: 20,
                      param_scope: :game_events)
  end
end

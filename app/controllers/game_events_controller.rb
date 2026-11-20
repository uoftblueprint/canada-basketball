class GameEventsController < ApplicationController
  include IndexTable

  scope_to_camp

  def create
    @game = current_camp.games.find(params.expect(:game_id))
    @game_event = @game.game_events.new(game_event_params)

    resolve_subject

    if @game_event.save
      @stat_lines_state = build_stat_lines_state
      Turbo::StreamsChannel.broadcast_replace_to(
        @game,
        target: ActionView::RecordIdentifier.dom_id(@game, :box_score_stat_lines),
        renderable: Games::StatLinesTableComponent.new(
          state: @stat_lines_state,
          game: @game,
          path_builder: ->(params) { box_score_camp_game_path(current_camp, @game, params) },
          table_id: ActionView::RecordIdentifier.dom_id(@game, :box_score_stat_lines)
        )
      )

      Turbo::StreamsChannel.broadcast_replace_to(
        @game,
        target: ActionView::RecordIdentifier.dom_id(@game, :show_stat_lines),
        renderable: Games::StatLinesTableComponent.new(
          state: @stat_lines_state,
          game: @game,
          path_builder: ->(params) { camp_game_path(current_camp, @game, params) },
          table_id: ActionView::RecordIdentifier.dom_id(@game, :show_stat_lines)
        )
      )
      redirect_to box_score_camp_game_path(current_camp, @game),
                  flash: { success: t(".success") },
                  status: :see_other
    else
      @game_events_state = build_events_table
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

  def build_events_table
    build_table_state(@game.game_events.includes(:player).order(created_at: :desc, id: :desc),
                      per_page: 20,
                      param_scope: :game_events)
                      
  def build_stat_lines_state
    build_table_state(@game.player_and_opponent_stat_lines, per_page: 50, param_scope: :stat_lines)
  end
end

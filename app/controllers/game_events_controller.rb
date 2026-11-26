class GameEventsController < ApplicationController
  include IndexTable

  scope_to_camp

  def create
    @game = current_camp.games.find(params.expect(:game_id))
    @game_event = @game.game_events.new(game_event_params)

    resolve_subject

    build_box_score_tables
    if @game_event.save
      broadcast_tables
      respond_to do |format|
        format.html do
          redirect_to box_score_camp_game_path(current_camp, @game),
                      flash: { success: t(".success") },
                      status: :see_other
        end
        format.turbo_stream do
          render :create
        end
      end
    else
      flash.now[:error] = @game_event.errors.full_messages.to_sentence
      render "games/box_score", formats: [:html], status: :unprocessable_content
    end
  end

  def destroy
    @game = current_camp.games.find(params.expect(:game_id))
    game_event = @game.game_events.find(params.expect(:id))
    if game_event.destroy
      build_box_score_tables
      broadcast_tables

      respond_to do |format|
        format.html do
          redirect_to box_score_camp_game_path(current_camp, @game),
                      flash: { success: t(".success") },
                      status: :see_other
        end
        format.turbo_stream do
          render :destroy
        end
      end
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
    @team_stat_rows = @game.team_stat_rows
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

  def broadcast_replace(target:, component:)
    Turbo::StreamsChannel.broadcast_replace_to(
      @game,
      target:,
      renderable: component
    )
  rescue StandardError => e
    Rails.logger.error(
      "Failed to broadcast #{target}: #{e.class} - #{e.message}"
    )
  end

  def broadcast_tables
    broadcast_replace(
      target: ActionView::RecordIdentifier.dom_id(@game, :box_score_game_events),
      component: Games::EventsTableComponent.new(
        state: @game_events_state,
        game: @game,
        path_builder: ->(params) { box_score_camp_game_path(current_camp, @game, params) },
        delete_path_builder: ->(event) { camp_game_game_event_path(current_camp, @game, event) },
        table_id: ActionView::RecordIdentifier.dom_id(@game, :box_score_game_events)
      )
    )

    broadcast_replace(
      target: ActionView::RecordIdentifier.dom_id(@game, :show_game_events),
      component: Games::EventsTableComponent.new(
        state: @game_events_state,
        game: @game,
        path_builder: ->(params) { camp_game_path(current_camp, @game, params) },
        delete_path_builder: ->(event) { camp_game_game_event_path(current_camp, @game, event) },
        table_id: ActionView::RecordIdentifier.dom_id(@game, :show_game_events)
      )
    )

    broadcast_replace(
      target: ActionView::RecordIdentifier.dom_id(@game, :box_score_stat_lines),
      component: Games::StatLinesTableComponent.new(
        state: @stat_lines_state,
        game: @game,
        path_builder: ->(params) { box_score_camp_game_path(current_camp, @game, params) },
        table_id: ActionView::RecordIdentifier.dom_id(@game, :box_score_stat_lines)
      )
    )

    broadcast_replace(
      target: ActionView::RecordIdentifier.dom_id(@game, :show_stat_lines),
      component: Games::StatLinesTableComponent.new(
        state: @stat_lines_state,
        game: @game,
        path_builder: ->(params) { camp_game_path(current_camp, @game, params) },
        table_id: ActionView::RecordIdentifier.dom_id(@game, :show_stat_lines)
      )
    )

    broadcast_replace(
      target: ActionView::RecordIdentifier.dom_id(@game, :team_stats_table),
      component: Games::TeamStatsTableComponent.new(
        rows: @team_stat_rows,
        table_id: ActionView::RecordIdentifier.dom_id(@game, :team_stats_table)
      )
    )
  end
end

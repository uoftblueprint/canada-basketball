class GamesController < ApplicationController
  include IndexTable

  scope_to_camp

  def show
    @game = current_camp.games.find(params.expect(:id))
    @stat_lines_state = build_stat_lines_state
    @team_stat_rows = @game.team_stat_rows
  end

  def box_score
    @game = current_camp.games.find(params.expect(:id))
    @stat_lines_state = build_stat_lines_state
    @team_stat_rows = @game.team_stat_rows
  end

  def new
    @game = current_camp.games.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @game = current_camp.games.find(params.expect(:id))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @game = current_camp.games.new(games_params)
    if @game.save
      redirect_to camp_game_path(current_camp, @game), flash: { success: t(".success") },
                                                       status: :see_other
    else
      flash.now[:error] = @game.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def update
    @game = current_camp.games.find(params.expect(:id))
    if @game.update(games_params)
      redirect_to camp_game_path(current_camp, @game), flash: { success: t(".success") },
                                                       status: :see_other
    else
      flash.now[:error] = @game.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @game = current_camp.games.find(params.expect(:id))
    if @game.destroy
      redirect_to camp_path(current_camp), flash: { success: t(".success") }, status: :see_other
    else
      redirect_back_or_to camp_path(current_camp), flash: { error: @game.errors.full_messages.to_sentence },
                                                   status: :see_other
    end
  end

  private

  def games_params
    params.expect(game: %i[name opponent_name team_id active])
  end

  def build_stat_lines_state
    build_table_state(@game.player_and_opponent_stat_lines, per_page: 50, param_scope: :stat_lines)
  end
end

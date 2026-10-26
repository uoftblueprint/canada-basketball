class GamesController < ApplicationController
  scope_to_camp

  def new
    @game = current_camp.games.new
  end

  def create
    @game = current_camp.games.new(games_params)
    if @game.save
      redirect_to camp_game_path(current_camp, @game), flash: { success: "Game created successfully" },
                                                       status: :see_other
    else
      flash.now[:error] = @game.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  private

  def games_params
    params.expect(game: %i[name opponent_name team_id])
  end
end

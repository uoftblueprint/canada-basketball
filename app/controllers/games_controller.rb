class GamesController < ApplicationController
  scope_to_camp

  def show
    @game = current_camp.games.find(params.expect(:id))
  end

  def new
    @game = current_camp.games.new
  end

  def edit
    @game = current_camp.games.find(params.expect(:id))
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

  def update
    @game = current_camp.games.find(params.expect(:id))
    if @game.update(games_params)
      redirect_to camp_game_path(current_camp, @game), flash: { success: "Game updated successfully" },
                                                       status: :see_other
    else
      flash.now[:error] = @game.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  private

  def games_params
    params.expect(game: %i[name opponent_name team_id])
  end
end

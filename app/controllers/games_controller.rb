class GamesController < ApplicationController
  scope_to_camp

  before_action :set_game, only: %i[show edit update destroy]

  def show; end

  def new
    @game = current_camp.games.new
  end

  def edit; end

  def create
    @game = current_camp.games.new(games_params)
    if @game.save
      redirect_to camp_game_path(current_camp, @game), flash: { success: "Game created successfully" }
    else
      flash.now[:error] = @game.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @game.update(games_params)
      redirect_to camp_game_path(current_camp, @game), flash: { success: "Game updated successfully" }
    else
      flash.now[:error] = @game.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @game.destroy
    redirect_to root_path, flash: { success: "Game was successfully deleted" }
  end

  private

  def games_params
    params.expect(game: %i[name opponent_name team_id])
  end

  def set_game
    @game = current_camp.games.find(params.expect(:id))
  end
end

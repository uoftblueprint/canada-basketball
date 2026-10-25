class PlayersController < ApplicationController
  before_action :require_admin, only: %i[destroy new create]

  def index
    @players = Player.includes(:team).order(:name)
  end

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to players_path, flash: { success: "Player created successfully" }, status: :see_other
    else
      flash.now[:error] = @player.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    player = Player.find(params.expect(:id))
    if player.destroy
      redirect_to root_path, flash: { success: "Player deleted successfully" }, status: :see_other
    else
      redirect_back_or_to root_path, flash: { error: player.errors.full_messages.to_sentence }, status: :see_other
    end
  end

  private

  def player_params
    params.expect(player: [:name])
  end
end

class PlayersController < ApplicationController
  before_action :require_admin, only: %i[destroy]

  def index
    @players = Player.includes(:team).order(:name)
  end

  def destroy
    player = Player.find(params.expect(:id))
    if player.destroy
      redirect_to root_path, flash: { success: "Player deleted successfully" }, status: :see_other
    else
      redirect_back_or_to root_path, flash: { error: player.errors.full_messages.to_sentence }, status: :see_other
    end
  end
end

class CampsController < ApplicationController
  before_action :require_admin, only: %i[index destroy]
  before_action :require_camp_login, only: :show
  scope_to_camp :id, only: :show

  def index
    @camps = Camp.order(active: :desc, name: :asc)
  end

  def show
    @camp = current_camp
    @players = @camp.players.includes(:team).order(:name)
    @games = @camp.games.includes(:team).order(:name)
  end

  def destroy
    camp = Camp.find(params.expect(:id))
    if camp.destroy
      redirect_to camps_path, flash: { success: "Camp deleted successfully" }, status: :see_other
    else
      redirect_back_or_to camps_path, flash: { error: camp.errors.full_messages.to_sentence }, status: :see_other
    end
  end

  private

  def require_camp_login
    return if logged_in_camp

    redirect_to login_path, flash: { error: "You must be logged in as a camp to access this page" }
  end
end

class CampsController < ApplicationController
  before_action :require_admin, only: %i[index new create destroy]
  scope_to_camp :id, only: :show

  def index
    @camps = Camp.order(active: :desc, name: :asc)
  end

  def show
    @camp = current_camp
    @players = @camp.players.includes(:team).order(:name)
    @games = @camp.games.includes(:team).order(:name)
  end

  def new
    @camp = Camp.new
    load_options
  end

  def create
    @camp = Camp.new(camp_params)

    if @camp.save
      redirect_to camp_path(@camp), flash: { success: "Camp created successfully" }, status: :see_other
    else
      flash.now[:error] = @camp.errors.full_messages.to_sentence
      load_options
      render :new, status: :unprocessable_content
    end
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

  def load_options
    @teams = Team.order(:name)
  end

  def camp_params
    params.expect(camp: [:name, :description, :password, :password_confirmation, :active, { team_ids: [] }])
  end
end

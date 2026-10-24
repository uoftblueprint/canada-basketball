class TeamsController < ApplicationController
  before_action :require_admin, only: %i[new create destroy]

  def index
    @teams = Team.order(:name)
  end

  def show
    @team = Team.includes(:players).find(params.expect(:id))
  end

  def new
    @team = Team.new
    load_options
  end

  def create
    @team = Team.new(team_params)

    if @team.save
      redirect_to new_team_path, flash: { success: "Team created successfully" }
    else
      flash.now[:error] = @team.errors.full_messages.to_sentence
      load_options
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    team = Team.find(params.expect(:id))
    if team.destroy
      redirect_to root_path, flash: { success: "Team deleted successfully" }, status: :see_other
    else
      redirect_back_or_to root_path, flash: { error: team.errors.full_messages.to_sentence }, status: :see_other
    end
  end

  private

  def load_options
    @players = Player.order(:name)
    @camps = Camp.order(:name)
  end

  def team_params
    params.expect(team: [:name, { player_ids: [], camp_ids: [] }])
  end
end

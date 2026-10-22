class TeamsController < ApplicationController
  before_action :require_admin, only: %i[new create]

  def index
    @teams = Team.order(:name)
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

  private

  def load_options
    @players = Player.order(:name)
    @camps = Camp.order(:name)
  end

  def team_params
    params.expect(team: [:name, { player_ids: [], camp_ids: [] }])
  end
end

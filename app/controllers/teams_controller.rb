class TeamsController < ApplicationController
  scope_to_camp
  before_action :require_admin, only: %i[new edit create update destroy]

  def show
    @team = current_camp.teams.includes(:players).find(params.expect(:id))
  end

  def new
    @team = current_camp.teams.new
    load_options
  end

  def edit
    @team = current_camp.teams.find(params.expect(:id))
    load_options
  end

  def create
    @team = current_camp.teams.new(team_params)

    if @team.save
      assign_players(@team)
      redirect_to camp_path(current_camp), flash: { success: "Team created successfully" }, status: :see_other
    else
      flash.now[:error] = @team.errors.full_messages.to_sentence
      load_options
      render :new, status: :unprocessable_content
    end
  end

  def update
    @team = current_camp.teams.find(params.expect(:id))
    if @team.update(team_params)
      assign_players(@team)
      redirect_to camp_path(current_camp), flash: { success: "Team updated successfully" }, status: :see_other
    else
      flash.now[:error] = @team.errors.full_messages.to_sentence
      load_options
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    team = current_camp.teams.find(params.expect(:id))
    if team.destroy
      redirect_to camp_path(current_camp), flash: { success: "Team deleted successfully" }, status: :see_other
    else
      redirect_back_or_to camp_path(current_camp), flash: { error: team.errors.full_messages.to_sentence },
                                                   status: :see_other
    end
  end

  private

  def assign_players(team)
    player_ids = params.dig(:team, :player_ids)
    return if player_ids.nil?

    player_ids = player_ids.compact_blank
    registrations = current_camp.camp_registrations
    # rubocop:disable Rails/SkipsModelValidations
    registrations.where(player_id: player_ids).update_all(team_id: team.id)
    registrations.where(team_id: team.id).where.not(player_id: player_ids).update_all(team_id: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def load_options
    @camp = current_camp
  end

  def team_params
    params.expect(team: [:name])
  end
end

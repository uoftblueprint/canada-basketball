class TeamsController < ApplicationController
  # Shows the name of all the players given the ID of a team.
  # Login is required, but that is supported through ApplicationController
  def show
    @team = Team.includes(:players).find(params.expect(:id))
  end
end

class CampsController < ApplicationController
  include IndexTable

  before_action :require_admin, only: %i[index new edit create update destroy]
  scope_to_camp :id, only: :show

  def index
    @table_state = build_table_state(Camp.order(active: :desc, name: :asc), per_page: 12, param_scope: :camps)
  end

  def show
    @camp = current_camp
    @teams = build_table_state(@camp.teams.order(:name), param_scope: :teams)
    @players = build_table_state(@camp.players.order(:name), param_scope: :players)
    @games = build_table_state(@camp.games.includes(:team).order(active: :desc, name: :asc), param_scope: :games)
    @player_teams = @camp.camp_registrations.includes(:team).index_by(&:player_id)
  end

  def new
    @camp = Camp.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @camp = Camp.find(params.expect(:id))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @camp = Camp.new(camp_params)

    if @camp.save
      redirect_to camp_path(@camp), flash: { success: t(".success") }, status: :see_other
    else
      flash.now[:error] = @camp.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def update
    @camp = Camp.find(params.expect(:id))

    if @camp.update(camp_params)
      redirect_to camp_path(@camp), flash: { success: t(".success") }, status: :see_other
    else
      flash.now[:error] = @camp.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
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

  def camp_params
    params.expect(camp: [:name, :description, :password, :password_confirmation, :active, { player_ids: [] }])
  end
end

class CampsController < ApplicationController
  before_action :require_admin, only: %i[index edit update destroy]
  before_action :set_camp, only: %i[edit update]

  def index
    @camps = Camp.order(active: :desc, name: :asc)
  end

  def edit
    load_options
  end

  def update
    if @camp.update(camp_params)
      redirect_to edit_camp_path(@camp), flash: { success: "Camp updated successfully" }, status: :see_other
    else
      load_options
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

  def set_camp
    @camp = Camp.find(params.expect(:id))
  end

  def load_options
    @teams = Team.order(:name)
  end

  def camp_params
    params.expect(camp: [:name, :description, :password, :password_confirmation, :active, { team_ids: [] }])
  end
end

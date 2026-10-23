class CampsController < ApplicationController
  before_action :require_admin, only: %i[index destroy]

  def index
    @camps = Camp.order(active: :desc, name: :asc)
  end

  def destroy
    camp = Camp.find(params.expect(:id))
    if camp.destroy
      redirect_to camps_path, flash: { success: "Camp deleted successfully" }, status: :see_other
    else
      redirect_back_or_to camps_path, flash: { error: camp.errors.full_messages.to_sentence }, status: :see_other
    end
  end

  scope_to_camp :id, only: :update

  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: ["Camp not found"] }, status: :not_found
  end

  def update
    if current_camp.update(camp_params)
      render json: current_camp.as_json(except: :password_digest)
    else
      render json: { errors: current_camp.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def camp_params
    params.expect(camp: %i[name description password password_confirmation active])
  end
end

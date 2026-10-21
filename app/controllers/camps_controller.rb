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
end

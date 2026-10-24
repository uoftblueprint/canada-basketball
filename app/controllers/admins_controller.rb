class AdminsController < ApplicationController
  before_action :require_admin

  def index
    @admins = Admin.order(:name)
  end

  def destroy
    admin = Admin.find(params.expect(:id))
    if admin.destroy
      redirect_to admins_path, flash: { success: "Admin deleted successfully" }, status: :see_other
    else
      redirect_back_or_to admins_path, flash: { error: admin.errors.full_messages.to_sentence }, status: :see_other
    end
  end
end

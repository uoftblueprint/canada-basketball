class AdminsController < ApplicationController
  before_action :require_admin

  def index
    @admins = Admin.order(:name)
  end

  def destroy
    admin = Admin.find(params.expect(:id))

    if Admin.count <= 1
      redirect_back_or_to admins_path, flash: {
        error: "Cannot delete admin because there is only one admin remaining"
      }, status: :see_other
    elsif admin.destroy
      redirect_to admins_path, flash: { success: "Admin deleted successfully" }, status: :see_other
    else
      redirect_back_or_to admins_path, flash: { error: admin.errors.full_messages.to_sentence }, status: :see_other
    end
  end
end

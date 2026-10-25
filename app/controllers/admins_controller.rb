class AdminsController < ApplicationController
  before_action :require_admin

  def index
    @admins = Admin.order(:name)
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    if @admin.save
      redirect_to root_path, flash: { success: t(".success") }, status: :see_other
    else
      flash.now[:error] = @admin.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
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

  private

  def admin_params
    params.expect(admin: %i[email name password password_confirmation])
  end
end

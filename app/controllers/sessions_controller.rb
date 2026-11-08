class SessionsController < ApplicationController
  skip_before_action :require_login

  def login
    @camps = Camp.all
  end

  def create
    camp = Camp.find_by(id: params[:camp_id])

    if camp&.authenticate(params[:password])
      reset_session
      # Use strings to prevent serialization confusion
      session[:identity] = { "type" => "camp", "id" => camp.id }
      redirect_to camp_path(camp), flash: { success: t(".success") }, status: :see_other
    else
      redirect_to login_path, flash: { error: t(".error") }, status: :see_other
    end
  end

  def login_admin; end

  def create_admin
    admin = Admin.find_by(email: params[:email])

    if admin&.authenticate(params[:password])
      reset_session
      # Use strings to prevent serialization confusion
      session[:identity] = { "type" => "admin", "id" => admin.id }
      redirect_to camps_path, flash: { success: t(".success") }, status: :see_other
    else
      redirect_to login_admin_path, flash: { error: t(".error") }, status: :see_other
    end
  end

  def destroy
    reset_session
    redirect_to login_path, flash: { success: t(".success") }, status: :see_other
  end
end

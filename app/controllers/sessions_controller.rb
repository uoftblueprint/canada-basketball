class SessionsController < ApplicationController
  skip_before_action :require_login

  def login
    @camps = Camp.all
  end

  def create
    camp = Camp.find_by(id: params[:camp_id])

    if camp&.authenticate(params[:password])
      reset_session
      session[:camp_id] = camp.id
      redirect_to root_path, flash: { success: "Logged in successfully" }
    else
      redirect_to login_path, flash: { error: "Invalid camp or password" }
    end
  end

  def login_admin; end

  def create_admin
    admin = Admin.find_by(email: params[:email])

    if admin&.authenticate(params[:password])
      reset_session
      session[:admin_id] = admin.id
      redirect_to root_path, flash: { success: "Logged in as admin successfully" }
    else
      redirect_to login_admin_path, flash: { error: "Invalid email or password" }
    end
  end

  def destroy
    reset_session
    redirect_to root_path, flash: { success: "Logged out successfully" }
  end
end

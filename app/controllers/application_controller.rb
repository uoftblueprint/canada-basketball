class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Require login before accessing page (ON by default)
  # Use skip_before_action to skip login
  before_action :require_login

  # Require admin before accessing page (OFF by default)
  # Add line below to require admin
  # before_action :require_admin

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def require_login
    return if logged_in?

    redirect_to login_path, flash: { error: "You must be logged in to access this page" }
  end

  def require_admin
    return if logged_in_as_admin?

    redirect_to login_path, flash: { error: "You must be logged in as an admin to access this page" }
  end

  def logged_in_admin
    @logged_in_admin ||= Admin.find_by(id: session[:admin_id]) if logged_in_as_admin?
  end

  def logged_in_camp
    @logged_in_camp ||= Camp.find_by(id: session[:camp_id]) if logged_in_as_camp?
  end
end

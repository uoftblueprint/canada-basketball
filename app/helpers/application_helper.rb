module ApplicationHelper
  def logged_in_as_admin? = !!session[:admin_id]
  def logged_in_as_camp? = !!session[:camp_id]
  def logged_in? = logged_in_as_admin? || logged_in_as_camp?
end

module Authentication
  extend ActiveSupport::Concern

  included do
    # By default, require login before accessing page (ON by default)
    # Use skip_before_action to skip login
    before_action :require_login
    helper_method :logged_in_state, :logged_in?, :logged_in_as_admin?, :logged_in_as_camp?, :logged_in_admin,
                  :logged_in_camp
  end

  class_methods do
    # Add to a controller to declare it "camp-scoped":
    # adds a current_camp helper method to get the camp from the URL, and
    # enforces that the camp from the URL matches the logged in camp
    def scope_to_camp(param = :camp_id, **options)
      before_action :require_camp_access, **options
      define_method(:current_camp) { @current_camp ||= Camp.find(params[param]) } # rubocop:disable Rails/StrongParametersExpect
      helper_method :current_camp
    end
  end

  private

  def require_login
    return if logged_in?

    redirect_to login_path, flash: { error: "You must be logged in to access this page" }
  end

  def require_admin
    return if logged_in_as_admin?

    redirect_to login_path, flash: { error: "You must be logged in as an admin to access this page" }
  end

  # Require that the user either be logged in as an admin,
  # or be logged in as the current camp
  def require_camp_access
    return if logged_in_admin
    return if logged_in_camp == current_camp

    redirect_to root_path, flash: { error: "You don't have access to this camp" }
  end

  def current_identity
    session[:identity]
  end

  def logged_in_state
    current_identity&.dig("type")&.to_sym || :logged_out
  end

  def logged_in_as_admin? = logged_in_state == :admin
  def logged_in_as_camp? = logged_in_state == :camp
  def logged_in? = logged_in_state != :logged_out

  def logged_in_admin
    @logged_in_admin ||= Admin.find_by(id: current_identity["id"]) if logged_in_as_admin?
  end

  def logged_in_camp
    @logged_in_camp ||= Camp.find_by(id: current_identity["id"]) if logged_in_as_camp?
  end
end

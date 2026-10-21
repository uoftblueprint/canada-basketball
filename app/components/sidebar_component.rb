class SidebarComponent < ViewComponent::Base
  attr_reader :logged_in_state, :sections

  SidebarSection = Data.define(:title, :items)
  SidebarItem = Data.define(:name, :icon, :path)

  def initialize(logged_in_state:)
    super()
    @logged_in_state = logged_in_state
    @sections = []
  end

  def before_render
    if logged_in_state == :admin
      build_admin_section
    elsif logged_in_state == :camp
      build_camp_section
    end
  end

  private

  def build_admin_section; end

  def build_camp_section; end

  def logout_item
    @logout_item ||= SidebarItem.new(name: "Logout", path: helpers.logout_path, icon: "sign-out")
  end

  def render?
    logged_in_state != :logged_out
  end
end

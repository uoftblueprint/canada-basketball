class SidebarComponent < ViewComponent::Base
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

  attr_reader :logged_in_state, :sections

  def build_admin_section
    sections << SidebarSection.new(
      title: nil,
      items: [
        nav_item(:admin, :camps, "trophy", helpers.camps_path),
        nav_item(:admin, :players, "user", helpers.players_path),
        nav_item(:admin, :admins, "star", helpers.admins_path)
      ]
    )
  end

  def build_camp_section
    camp = helpers.logged_in_camp
    sections << SidebarSection.new(
      title: nil,
      items: [
        nav_item(:camp, :camp, "trophy", helpers.camp_path(camp)),
        nav_item(:camp, :teams, "users-three", helpers.camp_path(camp, anchor: "teams")),
        nav_item(:camp, :games, "basketball", helpers.camp_path(camp, anchor: "games"))
      ]
    )
  end

  def nav_item(scope, key, icon, path)
    SidebarItem.new(name: t("sidebar_component.#{scope}.#{key}"), icon:, path:)
  end

  def logout_item
    @logout_item ||= SidebarItem.new(name: t("sidebar_component.logout"), path: helpers.logout_path, icon: "sign-out")
  end

  def active?(item)
    return false if item.path.include?("#")

    request.path == item.path || request.path.start_with?("#{item.path}/")
  end

  def render?
    logged_in_state != :logged_out
  end
end

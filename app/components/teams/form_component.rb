module Teams
  class FormComponent < ViewComponent::Base
    def initialize(camp:, team:)
      super()
      @camp = camp
      @team = team
    end

    private

    attr_reader :camp, :team

    def players
      camp.players.order(:name)
    end

    def team_label(player)
      registrations_by_player[player.id]&.team&.name || "No team"
    end

    def registrations_by_player
      @registrations_by_player ||= camp.camp_registrations.includes(:team).index_by(&:player_id)
    end
  end
end

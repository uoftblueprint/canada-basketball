module Teams
  class PlayerListComponent < ViewComponent::Base
    def initialize(team:)
      super()
      @team = team
    end

    private

    attr_reader :team
  end
end

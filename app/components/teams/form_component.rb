module Teams
  class FormComponent < ViewComponent::Base
    def initialize(team:, players:, camps:)
      super()
      @team = team
      @players = players
      @camps = camps
    end

    private

    attr_reader :team, :players, :camps
  end
end

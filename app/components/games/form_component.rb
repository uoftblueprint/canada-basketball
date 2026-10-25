module Games
  class FormComponent < ViewComponent::Base
    def initialize(game:, camp:)
      super()
      @game = game
      @camp = camp
    end

    private

    attr_reader :game, :camp
  end
end
module Camps
  class FormComponent < ViewComponent::Base
    def initialize(camp:, players:)
      super()
      @camp = camp
      @players = players
    end

    private

    attr_reader :camp, :players
  end
end

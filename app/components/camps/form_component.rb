module Camps
  class FormComponent < ViewComponent::Base
    def initialize(camp:, teams:)
      super()
      @camp = camp
      @teams = teams
    end

    private

    attr_reader :camp, :teams
  end
end

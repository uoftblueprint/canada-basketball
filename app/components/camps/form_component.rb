module Camps
  class FormComponent < ViewComponent::Base
    attr_reader :camp, :teams

    def initialize(camp:, teams:)
      super()
      @camp = camp
      @teams = teams
    end
  end
end

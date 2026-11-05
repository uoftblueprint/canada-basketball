# Renders a linked camp summary card for the camps index.
#
# The card displays the camp name, description, and localized active/inactive
# status. The link targets the top-level Turbo browsing context so navigation
# from inside the camps index frame loads the camp show page normally.
module Camps
  class CardComponent < ViewComponent::Base
    attr_reader :camp, :title, :description, :status_key, :status_class

    def initialize(camp:)
      super()
      @camp = camp
      @title = camp.name
      @description = camp.description
      @status_key = camp.active? ? "camps.card.active" : "camps.card.inactive"
      @status_class = camp.active? ? "badge-primary" : "badge-neutral"
    end
  end
end

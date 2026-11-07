module Camps
  class FormComponent < ViewComponent::Base
    def initialize(camp:)
      super()
      @camp = camp
    end

    private

    attr_reader :camp
  end
end

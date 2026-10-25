module Players
  class FormComponent < ViewComponent::Base
    def initialize(player:)
      super()
      @player = player
    end

    private

    attr_reader :player
  end
end

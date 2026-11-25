module Players
  class FormComponent < ViewComponent::Base
    def initialize(player:)
      super()
      @player = player
    end

    private

    attr_reader :player

    def province_options = Player.provinces.keys.map { |code| [Player.province_name(code), code] }
  end
end

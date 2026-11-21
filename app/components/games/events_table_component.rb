module Games
  class EventsTableComponent < ViewComponent::Base
    def initialize(state:, game:, path_builder:, delete_path_builder: nil)
      super()
      @state = state
      @game = game
      @path_builder = path_builder
      @delete_path_builder = delete_path_builder
    end

    private

    attr_reader :state, :game, :path_builder, :delete_path_builder

    def show_actions? = delete_path_builder.present?
  end
end

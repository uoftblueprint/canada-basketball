module Games
  class EventsTableComponent < ViewComponent::Base
    def initialize(state:, game:, path_builder:, delete_path_builder: nil, table_id:)
      super()
      @state = state
      @game = game
      @path_builder = path_builder
      @delete_path_builder = delete_path_builder
      @table_id = table_id
    end

    private

    attr_reader :state, :game, :path_builder, :delete_path_builder, :table_id

    def show_actions? = delete_path_builder.present?
  end
end

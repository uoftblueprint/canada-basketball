module Games
  class EventsTableComponent < ViewComponent::Base
    def initialize(state:, game:, path_builder:, table_id:, csv_path_builder: nil, delete_path_builder: nil)
      super()
      @state = state
      @game = game
      @path_builder = path_builder
      @csv_path_builder = csv_path_builder
      @delete_path_builder = delete_path_builder
      @table_id = table_id
    end

    private

    attr_reader :state, :game, :path_builder, :csv_path_builder, :delete_path_builder, :table_id

    def show_actions? = delete_path_builder.present?
  end
end

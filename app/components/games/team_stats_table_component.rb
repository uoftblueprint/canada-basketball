module Games
  class TeamStatsTableComponent < ViewComponent::Base
    STAT_COLUMNS = StatLinesTableComponent::STAT_COLUMNS

    def initialize(rows:, table_id:)
      super()
      @rows = rows
      @table_id = table_id
    end

    private

    attr_reader :rows, :table_id

    def format_stat(stats, column)
      value = stats.public_send(column)
      return value unless GameStatLine::PERCENTAGE_COLUMNS.include?(column)

      helpers.number_to_percentage(value.to_f * 100, precision: 0)
    end
  end
end

module Games
  class StatLinesTableComponent < ViewComponent::Base
    STAT_COLUMNS = %i[
      pts fgm fga fg_pct two_pm two_pa two_p_pct three_pm three_pa three_p_pct
      ftm fta ft_pct orb drb trb ast stl blk tov pf
    ].freeze

    def initialize(state:, game:, path_builder:)
      super()
      @state = state
      @game = game
      @path_builder = path_builder
    end

    private

    attr_reader :state, :game, :path_builder

    def name_for(line) = line.is_opponent? ? game.opponent_name : line.player.name

    def format_stat(line, column)
      value = line.public_send(column)
      return value unless GameStatLine::PERCENTAGE_COLUMNS.include?(column)

      helpers.number_to_percentage(value.to_f * 100, precision: 0)
    end
  end
end

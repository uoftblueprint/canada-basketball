module GameEvents
  class FormComponent < ViewComponent::Base
    COLUMN_KINDS = [
      %w[two_point_made three_point_made free_throw_made],
      %w[two_point_missed three_point_missed free_throw_missed],
      %w[assist turnover],
      %w[offensive_rebound defensive_rebound],
      %w[block steal foul]
    ].freeze

    def initialize(game:, camp:)
      super()
      @game = game
      @camp = camp
    end

    private

    attr_reader :game, :camp
  end
end

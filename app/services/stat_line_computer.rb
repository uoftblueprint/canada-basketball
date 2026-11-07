class StatLineComputer
  def self.call(...)
    new(...).call
  end

  def initialize(game_id:, player_id:, is_opponent:)
    @game_id = game_id
    @player_id = player_id
    @is_opponent = is_opponent
  end

  def call
    game_events = GameEvent.where(key)

    if game_events.empty?
      GameStatLine.destroy_by(key)
      return
    end

    totals = Hash.new(0)

    game_events.each do |game_event|
      GameEvent::STAT_DELTAS.fetch(game_event.kind.to_sym).each { |col, n| totals[col] += n }
    end
    GameStatLine::DERIVED_COLUMNS.each { |col, fn| totals[col] = fn.call(totals) }

    line = GameStatLine.find_or_initialize_by(key)
    line.assign_attributes(GameStatLine::COLUMNS.index_with { |col| totals[col] })
    line.save!
  end

  def key = { game_id: @game_id, player_id: @player_id, is_opponent: @is_opponent }
end

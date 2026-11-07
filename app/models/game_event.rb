class GameEvent < ApplicationRecord
  belongs_to :game
  belongs_to :player, optional: true

  STAT_DELTAS = {
    two_point_made: { two_pm: 1, two_pa: 1 },
    two_point_missed: { two_pa: 1 },
    three_point_made: { three_pm: 1, three_pa: 1 },
    three_point_missed: { three_pa: 1 },
    free_throw_made: { ftm: 1, fta: 1 },
    free_throw_missed: { fta: 1 },
    offensive_rebound: { orb: 1 },
    defensive_rebound: { drb: 1 },
    assist: { ast: 1 },
    turnover: { tov: 1 },
    foul: { pf: 1 },
    steal: { stl: 1 },
    block: { blk: 1 }
  }.freeze

  enum :kind, STAT_DELTAS.keys.index_with(&:to_s), validate: true

  validates :kind, presence: true
  validates :is_opponent, inclusion: { in: [true, false] }
  validate :opponent_events_have_no_player
  validate :player_on_game_team

  after_create  :recompute_line
  after_update  :recompute_line_and_previous
  after_destroy :recompute_line

  scope :chronological, -> { order(:created_at, :id) }

  private

  def opponent_events_have_no_player
    errors.add(:player, "must be blank for opponent events") if is_opponent? && player_id.present?
  end

  def player_on_game_team
    return if player_id.blank? || game.blank?

    errors.add(:player, "must be on the game's team") unless game.team.players.exists?(player.id)
  end

  def group_key
    { game_id: game_id, player_id: player_id, is_opponent: is_opponent }
  end

  def recompute_line
    StatLineComputer.call(**group_key)
  end

  # Recomputes the previous stat line that the event referred to as well, if any
  def recompute_line_and_previous
    recompute_line
    return unless saved_change_to_player_id? || saved_change_to_is_opponent?

    StatLineComputer.call(
      game_id: game_id,
      player_id: saved_change_to_player_id? ? saved_change_to_player_id.first : player_id,
      is_opponent: saved_change_to_is_opponent? ? saved_change_to_is_opponent.first : is_opponent
    )
  end
end

class GameStatLine < ApplicationRecord
  belongs_to :game
  belongs_to :player, optional: true

  scope :opponent, -> { where(is_opponent: true) }
  scope :individual_and_team_stats, -> { where(is_opponent: false) }
  scope :individual_stats, -> { where(is_opponent: false).where.not(player_id: nil) }
  scope :team_stats, -> { where(is_opponent: false, player_id: nil) }

  BASE_COLUMNS = GameEvent::STAT_DELTAS.values.flat_map(&:keys).uniq.freeze
  DERIVED_COLUMNS = {
    fgm: ->(t) { t[:two_pm] + t[:three_pm] },
    fga: ->(t) { t[:two_pa] + t[:three_pa] },
    trb: ->(t) { t[:orb] + t[:drb] },
    pts: ->(t) { (2 * t[:two_pm]) + (3 * t[:three_pm]) + t[:ftm] }
  }.freeze

  COLUMNS = (BASE_COLUMNS + DERIVED_COLUMNS.keys).freeze

  def fg_pct
    return 0.0 if fga.zero?

    fgm.fdiv(fga)
  end

  def two_p_pct
    return 0.0 if two_pa.zero?

    two_pm.fdiv(two_pa)
  end

  def three_p_pct
    return 0.0 if three_pa.zero?

    three_pm.fdiv(three_pa)
  end

  def ft_pct
    return 0.0 if fta.zero?

    ftm.fdiv(fta)
  end
end

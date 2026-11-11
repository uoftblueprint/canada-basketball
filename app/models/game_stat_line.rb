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
  PERCENTAGE_COLUMNS = %i[fg_pct two_p_pct three_p_pct ft_pct].freeze

  sortable_by(*COLUMNS, *PERCENTAGE_COLUMNS)

  def self.totals
    sum_exprs = COLUMNS.map { |c| "COALESCE(SUM(#{c}), 0) AS #{c}" }
    pct_exprs = {
      fg_pct: %w[fgm fga],
      two_p_pct: %w[two_pm two_pa],
      three_p_pct: %w[three_pm three_pa],
      ft_pct: %w[ftm fta]
    }.map { |name, (made, attempted)| "SUM(#{made}) * 1.0 / NULLIF(SUM(#{attempted}), 0) AS #{name}" }

    select(Arel.sql((sum_exprs + pct_exprs).join(", "))).take
  end
end

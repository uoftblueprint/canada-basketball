class Game < ApplicationRecord
  belongs_to :camp
  belongs_to :team

  searchable_by :name, :opponent_name
  sortable_by :name, :opponent_name

  validates :name, presence: true, uniqueness: { scope: :camp_id }
  validates :opponent_name, presence: true
  validates :active, inclusion: { in: [true, false] }
  validate :team_assigned_to_camp

  private

  def team_assigned_to_camp
    return if team.blank? || camp.blank?

    errors.add(:team, "must be assigned to this game's camp") unless camp.teams.exists?(team.id)
  end
end

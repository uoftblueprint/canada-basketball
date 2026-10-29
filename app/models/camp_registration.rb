class CampRegistration < ApplicationRecord
  belongs_to :camp
  belongs_to :player
  belongs_to :team, optional: true

  validates :player_id, uniqueness: { scope: :camp_id }
  validate :team_assigned_to_camp

  private

  def team_assigned_to_camp
    return if team.blank? || camp.blank?

    errors.add(:team, "must be assigned to this registrations's camp") unless team.camp_id == camp_id
  end
end

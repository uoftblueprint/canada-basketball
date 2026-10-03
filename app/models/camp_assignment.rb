class CampAssignment < ApplicationRecord
  belongs_to :team
  belongs_to :camp
  validates :team_id, uniqueness: { scope: :camp_id }
end

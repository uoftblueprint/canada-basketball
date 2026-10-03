class Team < ApplicationRecord
  # Can delete team without games; players become teamless
  has_many :players, dependent: :nullify
  # Cannot delete team that has played games
  has_many :games, dependent: :restrict_with_error
  has_many :camp_assignments, dependent: :destroy
  has_many :camps, through: :camp_assignments

  validates :name, presence: true
end

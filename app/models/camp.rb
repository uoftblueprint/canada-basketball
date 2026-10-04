class Camp < ApplicationRecord
  has_secure_password

  has_many :games, dependent: :restrict_with_error
  has_many :camp_assignments, dependent: :destroy
  has_many :teams, through: :camp_assignments
  has_many :players, through: :teams

  validates :name, presence: true, uniqueness: true
end

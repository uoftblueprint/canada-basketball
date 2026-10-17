class Camp < ApplicationRecord
  has_secure_password

  searchable_by :name, :description
  sortable_by :name, :description

  has_many :games, dependent: :restrict_with_error
  has_many :camp_assignments, dependent: :destroy
  has_many :teams, through: :camp_assignments
  has_many :players, through: :teams

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :active, inclusion: { in: [true, false] }
end

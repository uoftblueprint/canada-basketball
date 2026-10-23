class Team < ApplicationRecord
  belongs_to :camp
  has_many :games, dependent: :restrict_with_error
  has_many :camp_registrations, dependent: :nullify
  has_many :players, through: :camp_registrations

  validates :name, presence: true

  searchable_by :name
  sortable_by :name
end

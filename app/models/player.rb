class Player < ApplicationRecord
  has_many :camp_registrations
  has_many :camps, through: :camp_registrations
  has_many :game_events, dependent: :restrict_with_error

  searchable_by :name
  sortable_by :name

  validates :name, presence: true
end

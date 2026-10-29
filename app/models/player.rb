class Player < ApplicationRecord
  has_many :camp_registrations
  has_many :camps, through: :camp_registrations

  searchable_by :name
  sortable_by :name

  validates :name, presence: true
end

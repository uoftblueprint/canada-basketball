class Player < ApplicationRecord
  belongs_to :team, optional: true

  searchable_by :name
  sortable_by :name

  validates :name, presence: true
end

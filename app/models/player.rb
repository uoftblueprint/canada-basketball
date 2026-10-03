class Player < ApplicationRecord
  belongs_to :team, optional: true

  validates :name, presence: true
end

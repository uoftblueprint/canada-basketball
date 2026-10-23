class Camp < ApplicationRecord
  has_secure_password

  has_many :games, dependent: :restrict_with_error
  has_many :teams, dependent: :destroy
  has_many :camp_registrations, dependent: :destroy
  has_many :players, through: :camp_registrations

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :active, inclusion: { in: [true, false] }

  searchable_by :name, :description
  sortable_by :name, :description
end

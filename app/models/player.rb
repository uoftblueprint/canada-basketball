class Player < ApplicationRecord
  PROVINCES = %w[AB BC MB NB NL NS NT NU ON PE QC SK YT].freeze
  MIN_BIRTH_YEAR = 1900

  has_many :camp_registrations
  has_many :camps, through: :camp_registrations
  has_many :game_events, dependent: :restrict_with_error

  enum :province, PROVINCES.index_with(&:itself), prefix: true, validate: { allow_nil: true }

  searchable_by :name, :hometown
  sortable_by :name, :birth_year, :height_cm, :province, :hometown
  csv_exportable :id, :name, :birth_year, :height_cm, :province, :hometown, :created_at, :updated_at

  normalizes :province, :hometown, with: ->(value) { value.strip.presence }

  validates :name, presence: true
  validates :birth_year, numericality: {
    only_integer: true,
    greater_than_or_equal_to: MIN_BIRTH_YEAR,
    less_than_or_equal_to: -> { Date.current.year }
  }, allow_nil: true
  validates :height_cm, numericality: { only_integer: true, greater_than: 50, less_than: 300 }, allow_nil: true

  def self.province_name(code) = code && I18n.t("players.provinces.#{code}")

  def province_name = self.class.province_name(province)
end

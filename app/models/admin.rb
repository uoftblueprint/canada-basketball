class Admin < ApplicationRecord
  has_secure_password

  enum :role, { manager: "manager", analyst: "analyst" }, validate: true

  searchable_by :name, :email
  sortable_by :name, :email
  csv_exportable :id, :name, :email, :created_at, :updated_at

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end

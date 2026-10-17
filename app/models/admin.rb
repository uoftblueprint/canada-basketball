class Admin < ApplicationRecord
  has_secure_password

  searchable_by :name, :email
  sortable_by :name, :email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end

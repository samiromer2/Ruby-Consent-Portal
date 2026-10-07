class Citizen < ApplicationRecord
  has_many :consents, dependent: :destroy
  has_many :services, through: :consents

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end

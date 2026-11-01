class Citizen < ApplicationRecord
  belongs_to :user
  has_many :consents, dependent: :destroy
  has_many :services, through: :consents

  validates :user_id, uniqueness: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end

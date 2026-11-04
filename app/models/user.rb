class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :citizen, dependent: :destroy

  enum :role, { citizen: "citizen", admin: "admin" }, default: :citizen, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end

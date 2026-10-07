class Service < ApplicationRecord
  has_many :consents, dependent: :destroy
  has_many :citizens, through: :consents

  validates :name, presence: true
end

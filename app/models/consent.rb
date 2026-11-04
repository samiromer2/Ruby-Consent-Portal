class Consent < ApplicationRecord
  belongs_to :citizen
  belongs_to :service
  has_many :consent_events, dependent: :restrict_with_exception

  validates :service_id, uniqueness: { scope: :citizen_id, message: "already has consent from this citizen" }

  scope :active, -> { where(revoked_at: nil) }

  def active?
    revoked_at.nil?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end

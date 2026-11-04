class ConsentEvent < ApplicationRecord
  belongs_to :consent
  belongs_to :user, optional: true

  enum :action, { granted: "granted", revoked: "revoked", expired: "expired" }, validate: true

  validates :user, presence: true, unless: :expired?

  # Append-only. A saved event cannot be edited or deleted.
  def readonly?
    persisted?
  end

  def actor_name
    user&.email_address || "System"
  end
end

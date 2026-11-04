module Consents
  # Revoke is a person choosing to take a consent back. The expiry job does not
  # come through here: it writes an "expired" event with no user.
  class Revoke
    def self.call(consent:, user:)
      consent.transaction do
        consent.revoke!
        consent.consent_events.create!(action: :revoked, user:)
      end
    end
  end
end

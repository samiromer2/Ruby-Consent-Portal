class ExpireStaleConsentsJob < ApplicationJob
  queue_as :default

  def perform
    Consent.active.where(granted_at: ...1.year.ago).find_each do |consent|
      consent.transaction do
        consent.revoke!
        consent.consent_events.create!(action: :expired)
      end

      ConsentMailer.expired(consent).deliver_later
    end
  end
end

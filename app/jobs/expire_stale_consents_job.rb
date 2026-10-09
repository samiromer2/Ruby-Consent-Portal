class ExpireStaleConsentsJob < ApplicationJob
  queue_as :default

  def perform(*args)
     Consent.active.where(granted_at: ...1.year.ago).find_each(&:revoke!)
  end
end

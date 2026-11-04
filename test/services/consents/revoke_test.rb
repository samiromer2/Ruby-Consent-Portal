require "test_helper"

class Consents::RevokeTest < ActiveSupport::TestCase
  test "revokes the consent and writes exactly one event for that user" do
    consent = consents(:one)

    assert_difference("ConsentEvent.count", 1) do
      Consents::Revoke.call(consent:, user: users(:one))
    end

    event = consent.consent_events.sole
    assert event.revoked?
    assert_equal users(:one), event.user
    assert_not consent.reload.active?
  end
end

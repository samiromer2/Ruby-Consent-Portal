require "test_helper"

class ExpireStaleConsentsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  test "revokes consents older than a year and leaves recent ones alone" do
    ExpireStaleConsentsJob.perform_now

    assert_not_nil consents(:old).reload.revoked_at
    assert_nil consents(:one).reload.revoked_at
  end

  test "expiring writes exactly one system event and emails the citizen once" do
    assert_difference("ConsentEvent.count", 1) do
      assert_enqueued_email_with ConsentMailer, :expired, args: [ consents(:old) ] do
        ExpireStaleConsentsJob.perform_now
      end
    end

    event = consents(:old).consent_events.sole
    assert event.expired?
    assert_nil event.user
    assert_equal "System", event.actor_name
    assert_empty consents(:one).consent_events

    assert_no_enqueued_emails do
      ExpireStaleConsentsJob.perform_now
    end
    assert_equal 1, consents(:old).consent_events.count
  end
end
